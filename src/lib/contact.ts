export function buildBriefMailto(subject: string, body: string) {
  const params = new URLSearchParams({
    subject,
    body
  });

  return `mailto:info@perfectmission.co.uk?${params.toString()}`;
}
