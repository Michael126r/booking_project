from django.test import TestCase
from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken

User = get_user_model()


class UserModelTest(TestCase):
    def test_create_user(self):
        """Тест создания пользователя"""
        user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        self.assertEqual(user.username, 'testuser')
        self.assertEqual(user.email, 'test@example.com')
        self.assertTrue(user.check_password('testpass123'))

    def test_create_superuser(self):
        """Тест создания суперпользователя"""
        user = User.objects.create_superuser(
            username='admin',
            email='admin@example.com',
            password='adminpass123'
        )
        self.assertTrue(user.is_superuser)
        self.assertTrue(user.is_staff)


class UserRegistrationTest(APITestCase):
    def test_user_registration(self):
        """Тест регистрации пользователя через API"""
        url = reverse('register')
        data = {
            'username': 'newuser',
            'email': 'newuser@example.com',
            'password': 'newpass123',
            'password_confirm': 'newpass123'
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(User.objects.filter(email='newuser@example.com').exists())

    def test_user_registration_password_mismatch(self):
        """Тест регистрации с несовпадающими паролями"""
        url = reverse('register')
        data = {
            'username': 'newuser',
            'email': 'newuser@example.com',
            'password': 'newpass123',
            'password_confirm': 'differentpass'
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


class UserAuthTest(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='testuser',
            email='testuser@example.com',
            password='testpass123'
        )

    def test_login_successful(self):
        """Тест успешного входа в систему"""
        url = reverse('login')
        data = {
            'email': 'testuser@example.com',
            'password': 'testpass123'
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access_token', response.data)
        self.assertIn('refresh_token', response.data)
        self.assertIn('user', response.data)

    def test_login_invalid_credentials(self):
        """Тест входа с неверными учетными данными"""
        url = reverse('login')
        data = {
            'email': 'testuser@example.com',
            'password': 'wrongpass'
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_login_missing_fields(self):
        """Тест входа без обязательных полей"""
        url = reverse('login')
        data = {
            'email': 'testuser@example.com'
            # пароль отсутствует
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_logout_successful(self):
        """Тест успешного выхода из системы"""
        refresh = RefreshToken.for_user(self.user)
        url = reverse('logout')
        data = {
            'refresh_token': str(refresh)
        }
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_access_profile(self):
        """Тест доступа к профилю"""
        access = RefreshToken.for_user(self.user).access_token
        url = reverse('profile')
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {access}')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('user', response.data)
        self.assertEqual(response.data['user']['email'], 'testuser@example.com')

    def test_update_profile(self):
        """Тест обновления профиля"""
        access = RefreshToken.for_user(self.user).access_token
        url = reverse('profile')
        data = {
            'first_name': 'Test',
            'last_name': 'User',
            'phone': '+7-123-456-78-90',
            'department': 'IT'
        }
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {access}')
        response = self.client.put(url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['user']['first_name'], 'Test')
        self.assertEqual(response.data['user']['last_name'], 'User')

    def test_profile_unauthorized(self):
        """Тест доступа к профилю без авторизации"""
        url = reverse('profile')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_token_refresh(self):
        """Тест обновления токена"""
        refresh = RefreshToken.for_user(self.user)
        url = reverse('token_refresh')
        data = {
            'refresh': str(refresh)
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)

    def test_original_token_endpoint_compatibility(self):
        """Тест совместимости с оригинальным /api/token/"""
        url = reverse('token_obtain_pair')
        data = {
            'email': 'testuser@example.com',
            'password': 'testpass123'
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)
        self.assertIn('refresh', response.data)

    def test_login_get_method_info(self):
        """Тест информационного GET запроса к /api/login/"""
        url = reverse('login')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_405_METHOD_NOT_ALLOWED)
        self.assertIn('error', response.data)
        self.assertIn('usage', response.data)
        self.assertEqual(response.data['usage']['method'], 'POST')
