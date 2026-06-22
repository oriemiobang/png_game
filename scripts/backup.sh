#!/bin/bash
# Database Backup Script for PostgreSQL
# This script dumps the database and deletes backups older than 7 days.
# Usage: ./backup.sh

# Load environment variables (adjust path as needed)
# source /path/to/.env

DB_USER=${DB_USER:-postgres}
DB_NAME=${DB_NAME:-png_game}
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}

# Backup directory
BACKUP_DIR="/var/backups/png_game"
mkdir -p "$BACKUP_DIR"

# Timestamp format
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$TIMESTAMP.sql.gz"

echo "Starting backup for database: $DB_NAME"

# Run pg_dump and gzip it
# Note: Ensure PGPASSWORD is set in the environment or use ~/.pgpass
pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" | gzip > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
  echo "Backup successfully created at $BACKUP_FILE"
else
  echo "Error creating backup!"
  exit 1
fi

# Delete backups older than 7 days
echo "Cleaning up backups older than 7 days..."
find "$BACKUP_DIR" -type f -name "${DB_NAME}_*.sql.gz" -mtime +7 -exec rm {} \;

echo "Backup process completed."
