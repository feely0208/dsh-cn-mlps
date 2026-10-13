module.exports = {
  db: { password: process.env.DB_PASSWORD },
  api: { endpoint: 'https://api.example.com/v1' },
  crypto: { hash: (p) => bcrypt.hash(p, 12) }
};
