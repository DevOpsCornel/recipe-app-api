import time
from psycopg2 import OperationalError as Psycopg2OpError
from django.db.utils import OperationalError
from django.core.management.base import BaseCommand
from django.db import connections
from django.test import TestCase
from django.core.management import call_command




class Command(BaseCommand):
    help = 'Wait for the database to be available'

    def handle(self, *args, **options):
        self.stdout.write(self.style.SUCCESS('Waiting for database...'))
        db_up = False
        while not db_up:
            try:
                # Try to establish a database connection
                db_conn = connections['default']
                db_conn.ensure_connection()
                db_up = True
            except (Psycopg2OpError, OperationalError):
                self.stdout.write('Database unavailable, waiting 1 second...')
                time.sleep(1)

        self.stdout.write(self.style.SUCCESS('Database available!'))
