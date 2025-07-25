from django.contrib import admin
from django.urls import path, include
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods

@require_http_methods(["GET"])
def api_info(request):
    return JsonResponse({
        'message': 'Booking System API',
        'version': '1.1',
        'endpoints': {
            'admin': '/admin/',
            'register': '/api/register/',
            'login': '/api/login/',
            'logout': '/api/logout/',
            'profile': '/api/profile/',
            'token': '/api/token/',
            'refresh_token': '/api/token/refresh/',
            'rooms': '/api/rooms/',
            'bookings': '/api/bookings/',
        },
        'authentication': {
            'login_example': {
                'url': '/api/login/',
                'method': 'POST',
                'data': {
                    'email': 'test@example.com',
                    'password': 'testpass123'
                }
            },
            'usage': 'Include "Authorization: Bearer <access_token>" header in requests'
        },
        'documentation': {
            'admin_credentials': 'admin@example.com / admin123',
            'test_user': 'test@example.com / testpass123'
        }
    })

urlpatterns = [
    path('', api_info, name='api_info'),
    path('admin/', admin.site.urls),
    path('api/', include('accounts.urls')),
    path('api/', include('bookings.urls')),
]
