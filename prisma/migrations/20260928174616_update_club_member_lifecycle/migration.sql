/*
  Warnings:

  - A unique constraint covering the columns `[userId,clubId]` on the table `ClubMember` will be added. If there are existing duplicate values, this will fail.

*/
-- DropIndex
DROP INDEX "ClubMember_userId_clubId_key";

-- CreateIndex
CREATE UNIQUE INDEX "ClubMember_userId_clubId_key" ON "ClubMember"("userId", "clubId") WHERE ("leftAt" IS NULL);
