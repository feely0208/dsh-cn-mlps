module.exports = {
  db: { password: 'admin' },
  api: { endpoint: 'http://api.example.com/v1' },
  crypto: { hash: (password) => md5(password) },
  debug: true,
  // 反例：上下文不明，不该报
  etag: (p) => md5(p)
};
