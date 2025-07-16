from django.contrib import admin
from .models import Room, Booking

@admin.register(Room)
class RoomAdmin(admin.ModelAdmin):
    list_display = ('name', 'capacity', 'location', 'is_active', 'created_at')
    list_filter = ('is_active', 'capacity', 'created_at')
    search_fields = ('name', 'location')
    ordering = ('name',)
    
    fieldsets = (
        ('Основная информация', {
            'fields': ('name', 'capacity', 'location', 'is_active')
        }),
        ('Дополнительная информация', {
            'fields': ('description', 'equipment'),
            'classes': ('collapse',)
        })
    )

@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ('room', 'user', 'start_time', 'end_time', 'status', 'created_at')
    list_filter = ('status', 'room', 'start_time', 'created_at')
    search_fields = ('room__name', 'user__email', 'purpose')
    ordering = ('-start_time',)
    readonly_fields = ('created_at', 'updated_at')
    
    fieldsets = (
        ('Основная информация', {
            'fields': ('room', 'user', 'start_time', 'end_time', 'purpose')
        }),
        ('Статус', {
            'fields': ('status',)
        }),
        ('Временные метки', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        })
    )
    
    def get_queryset(self, request):
        return super().get_queryset(request).select_related('room', 'user')
