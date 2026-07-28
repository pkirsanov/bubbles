export async function submitRecord(body: unknown) {
  return fetch('/api/v1/records', { method: 'POST', body: JSON.stringify(body) });
}

export async function fetchLimits() {
  return fetch('/api/v1/records/limits');
}
