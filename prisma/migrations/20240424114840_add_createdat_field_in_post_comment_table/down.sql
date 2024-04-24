-- RedefineTables
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_PostComment" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "content" TEXT,
    "postId" INTEGER,
    FOREIGN KEY ("postId") REFERENCES "Post" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_PostComment" ("content", "id", "postId") SELECT "content", "id", "postId" FROM "PostComment";
DROP TABLE "PostComment";
ALTER TABLE "new_PostComment" RENAME TO "PostComment";
PRAGMA foreign_key_check;
PRAGMA foreign_keys=ON;

