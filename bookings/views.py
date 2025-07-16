from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from datetime import datetime, timedelta
from django.db.models import Q

from .models import Room, Booking
from .serializers import RoomSerializer, BookingSerializer, BookingCreateSerializer

class RoomViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Room.objects.filter(is_active=True)
    serializer_class = RoomSerializer
    permission_classes = [IsAuthenticated]
    
    @action(detail=True, methods=['get'])
    def availability(self, request, pk=None):
        """Проверка доступности комнаты на определенную дату"""
        room = self.get_object()
        date_str = request.query_params.get('date')
        
        if not date_str:
            return Response(
                {'error': 'Параметр date обязателен (формат: YYYY-MM-DD)'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            date = datetime.strptime(date_str, '%Y-%m-%d').date()
        except ValueError:
            return Response(
                {'error': 'Неверный формат даты. Используйте YYYY-MM-DD'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Получаем бронирования на указанную дату
        bookings = Booking.objects.filter(
            room=room,
            start_time__date=date,
            status__in=[Booking.StatusChoices.PENDING, Booking.StatusChoices.CONFIRMED]
        ).order_by('start_time')
        
        booking_data = []
        for booking in bookings:
            booking_data.append({
                'start_time': booking.start_time.strftime('%H:%M'),
                'end_time': booking.end_time.strftime('%H:%M'),
                'purpose': booking.purpose,
                'user_email': booking.user.email
            })
        
        return Response({
            'room': room.name,
            'date': date_str,
            'bookings': booking_data
        })

class BookingViewSet(viewsets.ModelViewSet):
    serializer_class = BookingSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Booking.objects.filter(user=self.request.user)
    
    def get_serializer_class(self):
        if self.action == 'create':
            return BookingCreateSerializer
        return BookingSerializer
    
    def create(self, request, *args, **kwargs):
        """Создание нового бронирования"""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        try:
            booking = serializer.save()
            return Response(
                BookingSerializer(booking).data,
                status=status.HTTP_201_CREATED
            )
        except Exception as e:
            return Response(
                {'error': str(e)}, 
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        """Отмена бронирования"""
        booking = self.get_object()
        
        if booking.status == Booking.StatusChoices.CANCELLED:
            return Response(
                {'error': 'Бронирование уже отменено'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        booking.status = Booking.StatusChoices.CANCELLED
        booking.save()
        
        return Response({
            'message': 'Бронирование успешно отменено',
            'booking_id': booking.id
        })
    
    @action(detail=False, methods=['get'])
    def my_bookings(self, request):
        """Получение всех бронирований текущего пользователя"""
        bookings = self.get_queryset().order_by('-start_time')
        
        # Фильтрация по статусу
        status_filter = request.query_params.get('status')
        if status_filter:
            bookings = bookings.filter(status=status_filter)
        
        # Фильтрация по дате
        date_from = request.query_params.get('date_from')
        date_to = request.query_params.get('date_to')
        
        if date_from:
            try:
                date_from = datetime.strptime(date_from, '%Y-%m-%d')
                bookings = bookings.filter(start_time__date__gte=date_from)
            except ValueError:
                return Response(
                    {'error': 'Неверный формат date_from. Используйте YYYY-MM-DD'}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
        
        if date_to:
            try:
                date_to = datetime.strptime(date_to, '%Y-%m-%d')
                bookings = bookings.filter(start_time__date__lte=date_to)
            except ValueError:
                return Response(
                    {'error': 'Неверный формат date_to. Используйте YYYY-MM-DD'}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
        
        page = self.paginate_queryset(bookings)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        
        serializer = self.get_serializer(bookings, many=True)
        return Response(serializer.data)
