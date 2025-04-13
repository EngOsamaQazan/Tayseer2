const { Client } = require('pg');
const fs = require('fs');
require('dotenv').config();

(async () => {
  try {
    const client = new Client({
      connectionString: process.env.DATABASE_URL,
      ssl: { rejectUnauthorized: false }
    });

    await client.connect();
    console.log('تم الاتصال بقاعدة البيانات بنجاح');

    await client.query('CREATE EXTENSION IF NOT EXISTS pgcrypto');
    
    const sql = fs.readFileSync('database.sql', 'utf8');
    const commands = sql.split(/;\s*$(?![^]*\/\*[^]*\*\/)/gm);
    // تقسيم الأوامر مع تجاهل الفواصل داخل التعليقات

    for (const command of commands) {
      if (command.trim()) {
        await client.query(command);
        console.log('تم تنفيذ الأمر بنجاح:', command.substring(0, 50) + '...');
      }
    }

    await client.end();
    console.log('تم تنفيذ جميع الأوامر بنجاح!');
  } catch (err) {
    console.error('حدث خطأ:', err);
    process.exit(1);
  }
})();