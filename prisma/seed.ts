import { PrismaClient } from "../src/generated/prisma/client/index.js";

const prisma = new PrismaClient();

async function main(){

    // cleaning seed for fresh data in an order, delete tasks first, then user
    await prisma.task.deleteMany();
    await prisma.user.deleteMany();

    // new seed data
    const user = await prisma.user.upsert({
        where: { email: "saad@example.com" },
        update: {},
        create: {
            name: "Saad",
            email: "saad@example.com",
            password: "hashedpassword123",
            tasks: {
                create: [
                    { title: "Set up Docker", description: "Initialize Docker and Postgres" },
                    { title: "Create Auth API", description: "Login, Signup, JWT refresh" },
                ],
            },
            isAdmin: true
        },
    });

    console.log({ user });
}

main()
    .then(() => console.log('Seeding complete'))
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });