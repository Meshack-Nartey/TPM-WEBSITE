-- AlterTable
ALTER TABLE "User" ADD COLUMN     "notifyEventsAndCamps" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "notifyNewSermons" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "notifyServiceReminders" BOOLEAN NOT NULL DEFAULT true;
