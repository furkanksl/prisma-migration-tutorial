/*
  Warnings:

  - You are about to drop the column `published` on the `PostComment` table. All the data in the column will be lost.
  - You are about to drop the column `title` on the `PostComment` table. All the data in the column will be lost.

*/
-- RedefineTables
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_PostComment" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "content" TEXT,
    "postId" INTEGER,
    CONSTRAINT "PostComment_postId_fkey" FOREIGN KEY ("postId") REFERENCES "Post" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_PostComment" ("content", "id", "postId") SELECT "content", "id", "postId" FROM "PostComment";
DROP TABLE "PostComment";
ALTER TABLE "new_PostComment" RENAME TO "PostComment";
PRAGMA foreign_key_check;
PRAGMA foreign_keys=ON;
