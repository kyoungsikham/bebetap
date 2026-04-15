-- Add optional height_cm column to babies table
ALTER TABLE babies ADD COLUMN IF NOT EXISTS height_cm numeric(5,2);
