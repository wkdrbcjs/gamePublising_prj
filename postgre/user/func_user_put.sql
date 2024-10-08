-- 2024/10/03 jang
-- 유저 정보 insert 및 update(p_user_serial_num가 null이 아닐때)

CREATE OR REPLACE FUNCTION public.func_user_put(
    -- 입력된 변수
    p_user_serial_num INT8,
    p_user_email TEXT,
    p_user_nick TEXT,
    p_user_auth_id UUID,
    p_user_point INT8,
    p_user_prof_img TEXT,
    p_is_email_rcv INT,
    p_create_at TIMESTAMPTZ,
    p_update_at TIMESTAMPTZ
)
-- 결과 반환을 위한 테이블
RETURNS TABLE (rst_val INT8, op TEXT, func_name TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_max_serial_num INT8;  -- 유저 테이블의 가장 높은 시리얼넘버
    v_rst_val INT8;         -- 200: insert, 201: update
    v_op TEXT;              -- 'insert', 'update'
    v_func_name TEXT = 'func_user_put';
    v_existing_user tb_user_mst%ROWTYPE;
begin

  -- 유저 시리얼 넘버가 null 이면 insert
    IF p_user_serial_num IS NULL THEN
        SELECT COALESCE(MAX(user_serial_num), -1) INTO v_max_serial_num FROM tb_user_mst;
        
        INSERT INTO tb_user_mst (
            user_serial_num, user_email, user_nick, user_auth_id,
            user_point, user_prof_img, is_email_rcv, create_at, update_at
        ) VALUES (
            v_max_serial_num + 1, p_user_email, p_user_nick, p_user_auth_id,
            p_user_point, p_user_prof_img, p_is_email_rcv, p_create_at, p_update_at
        );

        v_rst_val = 200;
        v_op = 'insert';

    -- 유저 시리얼 넘버가 null 아니면 update
    ELSE
        -- 기존 사용자 데이터 조회
        SELECT * INTO v_existing_user FROM tb_user_mst WHERE user_serial_num = p_user_serial_num;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'User with serial number % not found', p_user_serial_num;
        END IF;

        -- 변경된 필드만 업데이트
        UPDATE tb_user_mst
        SET 
            user_nick = CASE WHEN p_user_nick IS DISTINCT FROM v_existing_user.user_nick THEN p_user_nick ELSE v_existing_user.user_nick END,
            user_point = CASE WHEN p_user_point IS DISTINCT FROM v_existing_user.user_point THEN p_user_point ELSE v_existing_user.user_point END,
            user_prof_img = CASE WHEN p_user_prof_img IS DISTINCT FROM v_existing_user.user_prof_img THEN p_user_prof_img ELSE v_existing_user.user_prof_img END,
            is_email_rcv = CASE WHEN p_is_email_rcv IS DISTINCT FROM v_existing_user.is_email_rcv THEN p_is_email_rcv ELSE v_existing_user.is_email_rcv END,
            update_at = p_update_at
        WHERE user_serial_num = p_user_serial_num;

        v_rst_val = 201;
        v_op = 'update';
    END IF;

    RETURN QUERY SELECT v_rst_val, v_op, v_func_name;
END;
$$
;
