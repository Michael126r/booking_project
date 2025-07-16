from django.test import TestCase
from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient
from django.utils import timezone
from datetime import timedelta
from .models import Room, Booking

User = get_user_model()

class RoomModelTest(TestCase):
    def setUp(self):
        self.room = Room.objects.create(
            name='Conference Room',
            capacity=10,
            location='2э этаж'
        )

    def test_room_creation(self):
        self.assertEqual(self.room.name, 'Conference Room')
        self.assertEqual(self.room.capacity, 10)

    def test_room_uniqueness(self):
        with self.assertRaises(Exception):
            Room.objects.create(name='Conference Room', capacity=5)

class BookingModelTest(TestCase):
    def setUp(self):
        self.room = Room.objects.create(
            name='Conference Room',
            capacity=10,
            location='2э этаж'
        )
        self.user = User.objects.create_user(
            username='john_doe',
            email='john@example.com',
            password='testpass123'
        )

    def test_create_booking(self):
        future_time = timezone.now() + timedelta(days=1)
        booking = Booking.objects.create(
            room=self.room,
            user=self.user,
            start_time=future_time,
            end_time=future_time + timedelta(hours=1),
            purpose='Team Meeting'
        )
        self.assertEqual(booking.purpose, 'Team Meeting')


class BookingAPITest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.room = Room.objects.create(
            name='Conference Room',
            capacity=10,
            location='2э этаж'
        )
        self.user = User.objects.create_user(
            username='john_doe',
            email='john@example.com',
            password='testpass123'
        )
        
    def test_get_rooms(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.get(reverse('room-list'))
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_create_booking(self):
        self.client.force_authenticate(user=self.user)
        future_time = timezone.now() + timedelta(days=1)
        data = {
            'room': self.room.pk,
            'start_time': future_time.isoformat(),
            'end_time': (future_time + timedelta(hours=1)).isoformat(),
            'purpose': 'Team Meeting'
        }
        response = self.client.post(reverse('booking-list'), data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
