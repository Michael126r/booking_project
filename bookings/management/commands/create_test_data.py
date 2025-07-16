from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from bookings.models import Room, Booking
from datetime import datetime, timedelta
from django.utils import timezone

User = get_user_model()

class Command(BaseCommand):
    help = 'Создает тестовые данные для системы бронирования'

    def handle(self, *args, **options):
        # Создаем тестовые комнаты
        rooms_data = [
            {
                'name': 'Переговорная А',
                'capacity': 8,
                'location': '2 этаж, левое крыло',
                'description': 'Уютная переговорная для небольших встреч',
                'equipment': 'Проектор, доска, кофе-машина'
            },
            {
                'name': 'Переговорная Б',
                'capacity': 12,
                'location': '2 этаж, правое крыло',
                'description': 'Просторная комната для команды',
                'equipment': 'Большой экран, система аудио-конференций'
            },
            {
                'name': 'Зал совещаний',
                'capacity': 20,
                'location': '3 этаж',
                'description': 'Большой зал для презентаций и совещаний',
                'equipment': 'Проектор, микрофоны, система звука'
            },
            {
                'name': 'Креативная комната',
                'capacity': 6,
                'location': '1 этаж',
                'description': 'Комната для мозгового штурма',
                'equipment': 'Флипчарт, маркеры, пуфики'
            }
        ]

        for room_data in rooms_data:
            room, created = Room.objects.get_or_create(
                name=room_data['name'],
                defaults=room_data
            )
            if created:
                self.stdout.write(
                    self.style.SUCCESS(f'Создана комната: {room.name}')
                )
            else:
                self.stdout.write(
                    self.style.WARNING(f'Комната уже существует: {room.name}')
                )

        # Создаем тестового пользователя
        user_data = {
            'username': 'test_user',
            'email': 'test@example.com',
            'password': 'testpass123',
            'first_name': 'Тест',
            'last_name': 'Пользователь',
            'department': 'IT отдел'
        }

        user, created = User.objects.get_or_create(
            email=user_data['email'],
            defaults=user_data
        )
        
        if created:
            user.set_password(user_data['password'])
            user.save()
            self.stdout.write(
                self.style.SUCCESS(f'Создан пользователь: {user.email}')
            )
        else:
            self.stdout.write(
                self.style.WARNING(f'Пользователь уже существует: {user.email}')
            )

        # Создаем тестовые бронирования
        tomorrow = timezone.now() + timedelta(days=1)
        tomorrow = tomorrow.replace(hour=10, minute=0, second=0, microsecond=0)
        
        rooms = Room.objects.all()
        if rooms.exists():
            room = rooms.first()
            
            booking_data = {
                'room': room,
                'user': user,
                'start_time': tomorrow,
                'end_time': tomorrow + timedelta(hours=1),
                'purpose': 'Тестовая встреча команды',
                'status': 'confirmed'
            }
            
            booking, created = Booking.objects.get_or_create(
                room=room,
                start_time=tomorrow,
                defaults=booking_data
            )
            
            if created:
                self.stdout.write(
                    self.style.SUCCESS(f'Создано бронирование: {booking}')
                )
            else:
                self.stdout.write(
                    self.style.WARNING(f'Бронирование уже существует: {booking}')
                )

        self.stdout.write(
            self.style.SUCCESS('Тестовые данные успешно созданы!')
        )
