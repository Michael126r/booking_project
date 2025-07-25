from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.decorators import api_view, permission_classes
from django.contrib.auth import authenticate, get_user_model
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import UserRegistrationSerializer, CustomTokenObtainPairSerializer

User = get_user_model()

class RegisterView(APIView):
    permission_classes = [AllowAny]
    
    def post(self, request):
        serializer = UserRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response({
                'message': 'Пользователь успешно зарегистрирован',
                'user_id': user.id,
                'email': user.email
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer

class LoginView(APIView):
    permission_classes = [AllowAny]
    
    def get(self, request):
        """Возвращает информацию о том, как использовать login endpoint"""
        return Response({
            'error': 'Method GET not allowed',
            'message': 'Используйте POST запрос для входа в систему',
            'usage': {
                'method': 'POST',
                'url': '/api/login/',
                'content_type': 'application/json',
                'body': {
                    'email': 'your-email@example.com',
                    'password': 'your-password'
                },
                'example': {
                    'email': 'test@example.com',
                    'password': 'testpass123'
                }
            }
        }, status=status.HTTP_405_METHOD_NOT_ALLOWED)
    
    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')
        
        if not email or not password:
            return Response({
                'error': 'Email и пароль обязательны'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Аутентификация пользователя
        user = authenticate(request, username=email, password=password)
        
        if user is not None:
            if user.is_active:
                # Создание JWT токенов
                refresh = RefreshToken.for_user(user)
                access_token = refresh.access_token
                
                return Response({
                    'message': 'Успешная авторизация',
                    'access_token': str(access_token),
                    'refresh_token': str(refresh),
                    'user': {
                        'id': user.id,
                        'email': user.email,
                        'username': user.username,
                        'first_name': user.first_name,
                        'last_name': user.last_name,
                        'department': getattr(user, 'department', ''),
                        'phone': getattr(user, 'phone', '')
                    }
                }, status=status.HTTP_200_OK)
            else:
                return Response({
                    'error': 'Аккаунт пользователя деактивирован'
                }, status=status.HTTP_401_UNAUTHORIZED)
        else:
            return Response({
                'error': 'Неверные учетные данные'
            }, status=status.HTTP_401_UNAUTHORIZED)

class LogoutView(APIView):
    permission_classes = [IsAuthenticated]
    
    def post(self, request):
        try:
            refresh_token = request.data.get('refresh_token')
            if refresh_token:
                token = RefreshToken(refresh_token)
                token.blacklist()
            
            return Response({
                'message': 'Успешный выход из системы'
            }, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({
                'error': 'Ошибка при выходе из системы'
            }, status=status.HTTP_400_BAD_REQUEST)

class ProfileView(APIView):
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        user = request.user
        return Response({
            'user': {
                'id': user.id,
                'email': user.email,
                'username': user.username,
                'first_name': user.first_name,
                'last_name': user.last_name,
                'department': getattr(user, 'department', ''),
                'phone': getattr(user, 'phone', ''),
                'date_joined': user.date_joined,
                'is_staff': user.is_staff
            }
        }, status=status.HTTP_200_OK)
    
    def put(self, request):
        user = request.user
        
        # Обновляем разрешенные поля
        allowed_fields = ['first_name', 'last_name', 'phone', 'department']
        
        for field in allowed_fields:
            if field in request.data:
                setattr(user, field, request.data[field])
        
        user.save()
        
        return Response({
            'message': 'Профиль успешно обновлен',
            'user': {
                'id': user.id,
                'email': user.email,
                'username': user.username,
                'first_name': user.first_name,
                'last_name': user.last_name,
                'department': getattr(user, 'department', ''),
                'phone': getattr(user, 'phone', '')
            }
        }, status=status.HTTP_200_OK)
