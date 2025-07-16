from django.db import models
from django.contrib.auth import get_user_model
from django.core.exceptions import ValidationError
from django.utils import timezone

User = get_user_model()

class Room(models.Model):
    name = models.CharField(max_length=100, unique=True, verbose_name="Название комнаты")
    capacity = models.PositiveIntegerField(verbose_name="Вместимость")
    location = models.CharField(max_length=200, verbose_name="Расположение", default="Офис")
    description = models.TextField(blank=True, verbose_name="Описание")
    equipment = models.TextField(blank=True, verbose_name="Оборудование")
    is_active = models.BooleanField(default=True, verbose_name="Активна")
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = "Переговорная комната"
        verbose_name_plural = "Переговорные комнаты"
        ordering = ['name']
    
    def __str__(self):
        return self.name

class Booking(models.Model):
    class StatusChoices(models.TextChoices):
        PENDING = 'pending', 'Ожидает подтверждения'
        CONFIRMED = 'confirmed', 'Подтверждено'
        CANCELLED = 'cancelled', 'Отменено'
    
    room = models.ForeignKey(Room, on_delete=models.CASCADE, related_name='bookings')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='bookings')
    start_time = models.DateTimeField(verbose_name="Время начала")
    end_time = models.DateTimeField(verbose_name="Время окончания")
    purpose = models.CharField(max_length=200, verbose_name="Цель встречи")
    status = models.CharField(
        max_length=20,
        choices=StatusChoices.choices,
        default=StatusChoices.PENDING,
        verbose_name="Статус"
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = "Бронирование"
        verbose_name_plural = "Бронирования"
        ordering = ['-start_time']
    
    def clean(self):
        if self.start_time >= self.end_time:
            raise ValidationError("Время окончания должно быть позже времени начала")
        
        if self.start_time < timezone.now():
            raise ValidationError("Нельзя бронировать на прошедшее время")
        
        # Проверка пересечения с другими бронированиями
        overlapping_bookings = Booking.objects.filter(
            room=self.room,
            status__in=[self.StatusChoices.PENDING, self.StatusChoices.CONFIRMED]
        ).exclude(id=self.id)
        
        for booking in overlapping_bookings:
            if (self.start_time < booking.end_time and 
                self.end_time > booking.start_time):
                raise ValidationError(
                    f"Комната уже забронирована на это время: "
                    f"{booking.start_time.strftime('%H:%M')} - {booking.end_time.strftime('%H:%M')}"
                )
    
    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)
    
    def __str__(self):
        return f"{self.room.name} - {self.start_time.strftime('%d.%m.%Y %H:%M')}"
