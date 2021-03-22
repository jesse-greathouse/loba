export interface Server {
    id: number;
    host: string;
    weight: string;
    upstream_id: number;
    fail_timeout: string;
    backup: number;
    max_fails: string;
}