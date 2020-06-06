export interface Certificate {
  id: number;
  upstream_id: number;
  certificate: Blob;
  key: Blob;
}