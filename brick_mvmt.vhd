
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY brick_mvmt IS
    PORT (
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        ball_x : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        ball_y : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        red : OUT STD_LOGIC;
        green : OUT STD_LOGIC;
        blue : OUT STD_LOGIC;
        impact : OUT STD_LOGIC
    );
END brick_mvmt;

ARCHITECTURE Behavioral OF brick_mvmt IS
    -- Constants for brick layout
    CONSTANT q_rows : INTEGER := 4;  -- # of rows of bricks
    CONSTANT bpr : INTEGER := 10;  --  bricks per row
    CONSTANT brick_w : INTEGER := 50;
    CONSTANT brick_h : INTEGER := 20;
    CONSTANT s_row : INTEGER := 30;  -- space between rows
    CONSTANT y_start : INTEGER := 100;  -- starting Y pos for first row
    
    -- Types for brick arrays
    TYPE brick_positions IS ARRAY(0 TO q_rows - 1) OF STD_LOGIC_VECTOR(10 DOWNTO 0);
    TYPE brick_states IS ARRAY(0 TO q_rows - 1, 0 TO bpr - 1) OF STD_LOGIC;
    
    -- Signals for brick management
    SIGNAL brick_x_positions : brick_positions;
    SIGNAL brick_alive : brick_states := (OTHERS => (OTHERS => '1')); -- Initialize all bricks as alive
    SIGNAL move_counter : STD_LOGIC_VECTOR(19 DOWNTO 0) := (OTHERS => '0');
    
    -- Signals for brick display
    SIGNAL brick_on : STD_LOGIC;
    
    -- Component declaration for individual brick
    COMPONENT brick IS
        PORT (
            v_sync : IN STD_LOGIC;
            pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            row_num : IN INTEGER RANGE 0 TO 7;
            brick_x : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            brick_y : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            is_alive : IN STD_LOGIC;
            brick_on : OUT STD_LOGIC
        );
    END COMPONENT;

BEGIN
    -- Process to move bricks and handle wraparound
    move_bricks : PROCESS(v_sync)
    BEGIN
        IF rising_edge(v_sync) THEN
            -- Slow down brick movement using counter
            move_counter <= move_counter + 1;
            
            -- Move bricks every N v_sync pulses
            IF move_counter = 0 THEN
                FOR row IN 0 TO q_rows - 1 LOOP
                    -- Even rows move right, odd rows move left
                    IF (row MOD 2 = 0) THEN
                        -- Move right with wraparound
                        IF brick_x_positions(row) >= 800 - brick_w THEN
                            brick_x_positions(row) <= (OTHERS => '0');
                        ELSE
                            brick_x_positions(row) <= brick_x_positions(row) + 2;
                        END IF;
                    ELSE
                        -- Move left with wraparound
                        IF brick_x_positions(row) = 0 THEN
                            brick_x_positions(row) <= CONV_STD_LOGIC_VECTOR(800 - brick_w, 11);
                        ELSE
                            brick_x_positions(row) <= brick_x_positions(row) - 2;
                        END IF;
                    END IF;
                END LOOP;
            END IF;
        END IF;
    END PROCESS;

    -- Process to check for ball collisions with bricks
    check_impact : PROCESS(ball_x, ball_y)
    BEGIN
        impact <= '0';
        FOR row IN 0 TO q_rows-1 LOOP
            FOR col IN 0 TO bpr-1 LOOP
                IF brick_alive(row, col) = '1' THEN
                    -- Calculate brick position
                    IF (ball_x >= brick_x_positions(row) + (col * brick_w) AND
                        ball_x <= brick_x_positions(row) + ((col + 1) * brick_w) AND
                        ball_y >= CONV_STD_LOGIC_VECTOR(y_start + (row * s_row), 11) AND
                        ball_y <= CONV_STD_LOGIC_VECTOR(y_start + (row * s_row) + brick_h, 11)) THEN
                        brick_alive(row, col) <= '0';  -- destroy brick
                        impact <= '1';
                    END IF;
                END IF;
            END LOOP;
        END LOOP;
    END PROCESS;

    -- Set brick colors (can be modified for different row colors)
    brick_color : PROCESS(brick_on)
    BEGIN
        IF brick_on = '1' THEN
            red <= '1';
            green <= '1';
            blue <= '0';  -- Yellow bricks
        ELSE
            red <= '0';
            green <= '0';
            blue <= '0';
        END IF;
    END PROCESS;

END Behavioral;
