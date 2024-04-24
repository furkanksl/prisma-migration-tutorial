# Prisma Migration example with TypeScript

This example shows how to use [Prisma Client](https://www.prisma.io/docs/reference/tools-and-interfaces/prisma-client) in a **simple TypeScript script** to read and write data in a SQLite database. You can find the database file with some dummy data at [`./prisma/dev.db`](./prisma/dev.db).

##### important notes:

-   You should never edit your schemas in your db table editor. Every change for the tables should be done in `prisma.schema`. Otherwise migration history won't match and going to require hard reset for db which is we do not want to experience. `npx prisma db pull` should be only used on eding prisma to existing project that has a db.

-   `npx prisma migrate deploy` should be run in CI pipeline like github actions. You can also add into build step of your own CI.

-   If you are working with MongoDb, you have to use `npx prisma db push` instead of `npx migrate dev` .

## Getting started

### 1. Download example and install dependencies

Clone this example:

```
git clone git@github.com:furkanksl/prisma-migration-tutorial.git
```

Install npm dependencies:

```
cd prisma-migration-tutorial
npm install
```

### 2. Create the database

Run the following command to create your SQLite database file. This also creates the `User` and `Post` tables that are defined in [`prisma/schema.prisma`](./prisma/schema.prisma):

```
npx prisma migrate dev --name init
```

### 3. Run the script

Let's add dummy data into db.
Execute the script with this command:

```
npm run dev
```

## Evolving the app

Evolving the application typically requires two steps:

1. Migrate your database using Prisma Migrate
1. Update your application code

For the following example scenario, assume you want to add a "profile" feature to the app where users can create a profile and write a short bio about themselves.

### 1. Migrate your database using Prisma Migrate

The first step is to add a new table, e.g. called `Profile`, to the database. You can do this by adding a new model to your [Prisma schema file](./prisma/schema.prisma) file and then running a migration afterwards:

```diff
// schema.prisma

model Post {
  id        Int     @default(autoincrement()) @id
  title     String
  content   String?
  published Boolean @default(false)
  author    User?   @relation(fields: [authorId], references: [id])
  authorId  Int
}

model User {
  id      Int      @default(autoincrement()) @id
  name    String?
  email   String   @unique
  posts   Post[]
+ postComments PostComment[]
}

+model PostComment {
+  id        Int     @id @default(autoincrement())
+  content   String?
+  post      Post?   @relation(fields: [postId], references: [id])
+  postId    Int?
+}
```

Once you've updated your data model, you can execute the changes against your database with the following command:

```
npx prisma migrate dev
```

### 2. Update your application code

You can now use your `PrismaClient` instance to perform operations against the new `PostComment` table.

### 3. Push your schema changes to production

You should run this command in a CI pipeline like github actions. You can also add into build step of your own CI.

```
npx prisma migrate deploy
```

### 4. Rollback ( for down migrations )

To be able to rollback when you have down migration (failed migration), Prisma provides you a `npx prisma migrate diff`. This step should be done before you create a new migration.

```
npx prisma migrate diff \
 --from-schema-datamodel prisma/schema.prisma \
 --to-schema-datasource prisma/schema.prisma \
 --script > down.sql
```

You can put that `down.sql` file into last successfull migration's folder in `prisma/migrations` by manual or just giving a path in command above.

Basically, `down.sql` file will include whats changed from last migration.

By running this command, you are able to rollback to last migration if your current migration has failed.

`npx prisma migrate resolve --rolled-back 20240424114840_add_createdat_field_in_post_comment_table`

### 5. If you already experience the db reset issue, you can set baseline of migrations with commands below:
```
mkdir -p prisma/migrations/0_init

npx prisma migrate diff \
--from-empty \
--to-schema-datamodel prisma/schema.prisma \
--script > prisma/migrations/0_init/migration.sql

npx prisma migrate resolve --applied 0_init
```
[Baselining](https://www.prisma.io/docs/orm/prisma-migrate/workflows/baselining)

## Switch to another database (e.g. PostgreSQL, MySQL, SQL Server, MongoDB)

If you want to try this example with another database than SQLite, you can adjust the the database connection in [`prisma/schema.prisma`](./prisma/schema.prisma) by reconfiguring the `datasource` block.

Learn more about the different connection configurations in the [docs](https://www.prisma.io/docs/reference/database-reference/connection-urls).

<details><summary>Expand for an overview of example configurations with different databases</summary>

### PostgreSQL

For PostgreSQL, the connection URL has the following structure:

```prisma
datasource db {
  provider = "postgresql"
  url      = "postgresql://USER:PASSWORD@HOST:PORT/DATABASE?schema=SCHEMA"
}
```

Here is an example connection string with a local PostgreSQL database:

```prisma
datasource db {
  provider = "postgresql"
  url      = "postgresql://janedoe:mypassword@localhost:5432/notesapi?schema=public"
}
```

### MySQL

For MySQL, the connection URL has the following structure:

```prisma
datasource db {
  provider = "mysql"
  url      = "mysql://USER:PASSWORD@HOST:PORT/DATABASE"
}
```

Here is an example connection string with a local MySQL database:

```prisma
datasource db {
  provider = "mysql"
  url      = "mysql://janedoe:mypassword@localhost:3306/notesapi"
}
```

### Microsoft SQL Server

Here is an example connection string with a local Microsoft SQL Server database:

```prisma
datasource db {
  provider = "sqlserver"
  url      = "sqlserver://localhost:1433;initial catalog=sample;user=sa;password=mypassword;"
}
```

### MongoDB

Here is an example connection string with a local MongoDB database:

```prisma
datasource db {
  provider = "mongodb"
  url      = "mongodb://USERNAME:PASSWORD@HOST/DATABASE?authSource=admin&retryWrites=true&w=majority"
}
```

</details>

-   Check out the [Prisma docs](https://www.prisma.io/docs)
