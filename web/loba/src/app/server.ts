export interface Server {
    id: number;
    host: string;
    weight: boolean;
    upstream_id: number;
    fail_timeout: number;
    backup: number;
    max_fails: number;
}