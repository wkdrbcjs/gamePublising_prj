-- 오시라세 불러오기 
-- p_get_count이 있으면 그 값만큼
-- p_get_count이 null이면 전체 조회

CREATE OR REPLACE FUNCTION func_news_get(
    p_get_count INTEGER DEFAULT NULL
)
RETURNS SETOF tb_news_mst AS $$
BEGIN
    IF p_get_count IS NULL THEN
        -- 전체 뉴스 항목 반환
        RETURN QUERY
        SELECT *
        FROM tb_news_mst n
        ORDER BY n.news_serial_num DESC;
    ELSE
        -- 지정된 개수만큼의 최신 뉴스 항목 반환
        RETURN QUERY
        SELECT *
        FROM tb_news_mst n
        ORDER BY n.news_serial_num DESC
        LIMIT p_get_count;
    END IF;
END;
$$
 LANGUAGE plpgsql;
