from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model

User = get_user_model()

class Command(BaseCommand):
    help = 'Создает суперпользователя для тестирования'

    def handle(self, *args, **options):
        if not User.objects.filter(email='admin@example.com').exists():
            User.objects.create_superuser(
                username='admin',
                email='admin@example.com',
                password='admin123'
            )
            self.stdout.write(
                self.style.SUCCESS('Суперпользователь создан: admin@example.com / admin123')
            )
        else:
            self.stdout.write(
                self.style.WARNING('Суперпользователь уже существует')
            )
