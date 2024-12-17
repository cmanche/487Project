-- BASED FROM FILE USED IN LAB, CHANGES ARE COMMENTED
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY bat_n_ball IS
    PORT (
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        -- CHANGE: Modified to have y positions for both bats instead of x position
        bat1_y : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- current left bat y position
        bat2_y : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- current right bat y position
--      bat_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- current bat x position
        serve : IN STD_LOGIC; -- initiates serve
        red : OUT STD_LOGIC;
        green : OUT STD_LOGIC;
        blue : OUT STD_LOGIC;
        -- CHANGE: Added score outputs for both players
        score1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        score2 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        speed_mode : IN STD_LOGIC_VECTOR(2 DOWNTO 0);  -- speed mode input
        -- CHANGE: Added color inversion controls
        invert_background : IN STD_LOGIC;
        invert_paddles : IN STD_LOGIC;
        -- CHANGE: Added random bounce control
        random_bounce : IN STD_LOGIC
    );
END bat_n_ball;

ARCHITECTURE Behavioral OF bat_n_ball IS
    CONSTANT bsize : INTEGER := 8; -- ball size in pixels
--  CONSTANT bat_w : INTEGER := 20; -- bat width in pixels
--  CONSTANT bat_h : INTEGER := 3; -- bat height in pixels
    -- CHANGE: Modified bat dimensions for vertical orientation
    CONSTANT bat_w : INTEGER := 3; -- bat width in pixels
    CONSTANT bat_h : INTEGER := 50; -- bat height in pixels
--  CHANGE: Added fixed x positions for both bats
    CONSTANT bat1_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(20, 11);
    CONSTANT bat2_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(780, 11);
--  distance ball moves each frame
--  CONSTANT ball_speed : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (6, 11);
--  CHNAGE: constant speed altered to variable speed based on switches
    CONSTANT ball_speed_normal : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (6, 11);
    CONSTANT ball_speed_fast : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (8, 11);
    CONSTANT ball_speed_faster : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (10, 11);
    
    SIGNAL ball_speed : STD_LOGIC_VECTOR (10 DOWNTO 0);
    
    SIGNAL ball_on : STD_LOGIC; -- indicates whether ball is at current pixel position
--  SIGNAL bat_on : STD_LOGIC; -- indicates whether bat at over current pixel position
--  CHNAGE
    SIGNAL bat1_on : STD_LOGIC; -- indicates whether left bat is at current pixel position
    SIGNAL bat2_on : STD_LOGIC; -- indicates whether right bat is at current pixel position
    
    SIGNAL game_on : STD_LOGIC := '0'; -- indicates whether ball is in play
    -- current ball position - intitialized to center of screen
    SIGNAL ball_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
    SIGNAL ball_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
    -- bat vertical position
    CONSTANT bat_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11);
    -- current ball motion - initialized to (+ ball_speed) pixels/frame in both X and Y directions
    SIGNAL ball_x_motion, ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := ball_speed;
    
    -- CHANGE: score track
    SIGNAL score1_reg : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";  -- Initialize to zero
    SIGNAL score2_reg : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";  -- Initialize to zero
    
    SIGNAL score1_count : INTEGER RANGE 0 TO 15 := 0;  -- Extended range to handle 10-15
    SIGNAL score2_count : INTEGER RANGE 0 TO 15 := 0;

    
    -- CHANGE: serve control signals
    SIGNAL serve_count : STD_LOGIC := '0';  -- Toggles every serve
    SIGNAL serve_dir : STD_LOGIC := '0';    -- Toggles every two serves
    SIGNAL serve_angle : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";  -- For varying 
    
    SIGNAL center_line : STD_LOGIC;
    
    -- CHANGE: Added random number generator signals for paddle bounces
    SIGNAL rand_counter : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL rand_value : STD_LOGIC_VECTOR(2 DOWNTO 0);
    
    -- CHANGE: Added color control signals
    SIGNAL background_color : STD_LOGIC;
    SIGNAL ball_color : STD_LOGIC;
    SIGNAL paddle_color : STD_LOGIC;
    
BEGIN
--    red <= NOT bat_on; -- color setup for red ball and cyan bat on white background
--    green <= NOT ball_on;
--    blue <= NOT ball_on;
    -- CHANGE: Color control based on inversion settings
    center_line <= '1' when (pixel_col >= 398 and pixel_col <= 402) else '0';
    background_color <= invert_background;
    ball_color <= NOT invert_background;
    paddle_color <= '1' WHEN invert_paddles = '0' ELSE '0';
-- COlor reassignment + center line
-- no color for ball = black
--    red <= bat1_on  OR center_line;
--    green <= center_line OR (NOT (bat1_on OR bat2_on OR ball_on)); -- Green background
--    blue <= bat2_on OR center_line;
    -- CHANGE: Modified color assignments
    red <= (bat1_on AND NOT invert_paddles) OR  -- Left paddle red when not inverted
           (bat2_on AND invert_paddles) OR      -- Right paddle red when inverted
           center_line;                         -- Center line always white
           
    green <= (NOT (bat1_on OR bat2_on OR ball_on) AND NOT invert_background) OR  -- Green background when not inverted
             (ball_on AND invert_background) OR                                   -- Green ball when inverted
             center_line;                                                        -- Center line always white
             
    blue <= (bat2_on AND NOT invert_paddles) OR  -- Right paddle blue when not inverted
            (bat1_on AND invert_paddles) OR      -- Left paddle blue when inverted
            center_line;                         -- Center line always white
    
    --  score update
    score1 <= score1_reg;
    score2 <= score2_reg;    
        -- Process to set speed based on switches
    -- CHANGE: Random number generator process
    random_gen : PROCESS(v_sync)
    BEGIN
        IF rising_edge(v_sync) THEN
            rand_counter <= rand_counter + 1;
        END IF;
    END PROCESS;
    
    rand_value <= rand_counter;
        
    process(speed_mode)
    begin
        case speed_mode is
            when "001" => ball_speed <= ball_speed_normal;
            when "010" => ball_speed <= ball_speed_fast;
            when "100" => ball_speed <= ball_speed_faster;
            when others => ball_speed <= ball_speed_normal;
        end case;
    end process;

    -- process to draw round ball
    -- set ball_on if current pixel address is covered by ball position
    balldraw : PROCESS (ball_x, ball_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF pixel_col <= ball_x THEN -- vx = |ball_x - pixel_col|
            vx := ball_x - pixel_col;
        ELSE
            vx := pixel_col - ball_x;
        END IF;
        IF pixel_row <= ball_y THEN -- vy = |ball_y - pixel_row|
            vy := ball_y - pixel_row;
        ELSE
            vy := pixel_row - ball_y;
        END IF;
        IF ((vx * vx) + (vy * vy)) < (bsize * bsize) THEN -- test if radial distance < bsize
            ball_on <= game_on;
        ELSE
            ball_on <= '0';
        END IF;
    END PROCESS;
    -- process to draw bat
--    -- set bat_on if current pixel address is covered by bat position
--    batdraw : PROCESS (bat_x, pixel_row, pixel_col) IS
--        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
--    BEGIN
--        IF ((pixel_col >= bat_x - bat_w) OR (bat_x <= bat_w)) AND
--         pixel_col <= bat_x + bat_w AND
--             pixel_row >= bat_y - bat_h AND
--             pixel_row <= bat_y + bat_h THEN
--                bat_on <= '1';
--        ELSE
--            bat_on <= '0';
--        END IF;
--    END PROCESS;
    -- new batS process
    batdraw : PROCESS (bat1_y, bat2_y, pixel_row, pixel_col) IS
    BEGIN
        -- Left bat
        IF pixel_col >= (bat1_x - bat_w) AND
           pixel_col <= (bat1_x + bat_w) AND
           pixel_row >= (bat1_y - bat_h) AND
           pixel_row <= (bat1_y + bat_h) THEN
            bat1_on <= '1';
        ELSE
            bat1_on <= '0';
        END IF;
        
        -- Right bat
        IF pixel_col >= (bat2_x - bat_w) AND
           pixel_col <= (bat2_x + bat_w) AND
           pixel_row >= (bat2_y - bat_h) AND
           pixel_row <= (bat2_y + bat_h) THEN
            bat2_on <= '1';
        ELSE
            bat2_on <= '0';
        END IF;
    END PROCESS;    
    -- process to move ball once every frame (i.e., once every vsync pulse)
    mball : PROCESS
        VARIABLE temp : STD_LOGIC_VECTOR (11 DOWNTO 0);
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
--        IF serve = '1' AND game_on = '0' THEN -- test for new serve
--            game_on <= '1';
--            ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
--        ELSIF ball_y <= bsize THEN -- bounce off top wall
--            ball_y_motion <= ball_speed; -- set vspeed to (+ ball_speed) pixels
--        ELSIF ball_y + bsize >= 600 THEN -- if ball meets bottom wall
--            ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
--            game_on <= '0'; -- and make ball disappear
--        END IF;
--        -- allow for bounce off left or right of screen
--        IF ball_x + bsize >= 800 THEN -- bounce off right wall
--            ball_x_motion <= (NOT ball_speed) + 1; -- set hspeed to (- ball_speed) pixels
--        ELSIF ball_x <= bsize THEN -- bounce off left wall
--            ball_x_motion <= ball_speed; -- set hspeed to (+ ball_speed) pixels
--        END IF;

    -- base off, but now logic is rotated ess3entially
--        IF serve = '1' AND game_on = '0' THEN
--            game_on <= '1';
--            ball_y_motion <= ball_speed;
--            -- CHANGE: Randomize initial direction
--            IF ball_x < 400 THEN
--                ball_x_motion <= ball_speed;
--            ELSE
--                ball_x_motion <= (NOT ball_speed) + 1;
--            END IF;
--        END IF;

        -- CHANGE: enhanced serve behavior with direction alternation and varying angles
        IF serve = '1' AND game_on = '0' THEN
            game_on <= '1';
            serve_count <= NOT serve_count;
            
            -- Update serve direction every two serves
            IF serve_count = '1' THEN
                serve_dir <= NOT serve_dir;
            END IF;
            
            -- Update angle selection
            serve_angle <= serve_angle + "01";
            
            -- Set initial ball direction
            IF serve_dir = '0' THEN  -- Serve left
                ball_x_motion <= (NOT ball_speed) + 1;  -- Left
                CASE serve_angle IS
                    WHEN "00" => ball_y_motion <= (NOT (ball_speed - 2)) + 1;  -- Slight up
                    WHEN "01" => ball_y_motion <= ball_speed;                   -- Down
                    WHEN "10" => ball_y_motion <= (NOT ball_speed) + 1;        -- Up
                    WHEN OTHERS => ball_y_motion <= (ball_speed - 2);          -- Slight down
                END CASE;
            ELSE  -- Serve right
                ball_x_motion <= ball_speed;  -- Right
                CASE serve_angle IS
                    WHEN "00" => ball_y_motion <= (NOT (ball_speed - 2)) + 1;  -- Slight up
                    WHEN "01" => ball_y_motion <= ball_speed;                   -- Down
                    WHEN "10" => ball_y_motion <= (NOT ball_speed) + 1;        -- Up
                    WHEN OTHERS => ball_y_motion <= (ball_speed - 2);          -- Slight down
                END CASE;
            END IF;
            
            -- Reset ball position
            ball_x <= CONV_STD_LOGIC_VECTOR(400, 11);
            ball_y <= CONV_STD_LOGIC_VECTOR(300, 11);
        END IF;
        
        -- Bounce off top and bottom walls
        IF ball_y <= bsize THEN
            ball_y_motion <= ball_speed;
        ELSIF ball_y + bsize >= 600 THEN
            ball_y_motion <= (NOT ball_speed) + 1;
        END IF;    
        
        
--        -- allow for bounce off bat
--        IF (ball_x + bsize/2) >= (bat_x - bat_w) AND
--         (ball_x - bsize/2) <= (bat_x + bat_w) AND
--             (ball_y + bsize/2) >= (bat_y - bat_h) AND
--             (ball_y - bsize/2) <= (bat_y + bat_h) THEN
--                ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
--        END IF;

        -- SCORING LOGIC
        IF ball_x + bsize >= 800 THEN  -- Right wall, point for player 1
            score1_count <= score1_count + 1;
            -- Convert integer directly to the correct hex value for display
            score1_reg <= CONV_STD_LOGIC_VECTOR(score1_count + 1, 4);  -- Add 1 here for immediate update
            game_on <= '0';
            ball_x <= CONV_STD_LOGIC_VECTOR(400, 11);
            ball_y <= CONV_STD_LOGIC_VECTOR(300, 11);
        ELSIF ball_x <= bsize THEN     -- Left wall, point for player 2
            score2_count <= score2_count + 1;
            -- Convert integer directly to the correct hex value for display
            score2_reg <= CONV_STD_LOGIC_VECTOR(score2_count + 1, 4);  -- Add 1 here for immediate update
            game_on <= '0';
            ball_x <= CONV_STD_LOGIC_VECTOR(400, 11);
            ball_y <= CONV_STD_LOGIC_VECTOR(300, 11);
        END IF;

        
--         with l & r handling
--         CHANGE: Handle bat collisions for both bats
--      --   Left bat collision
--        IF (ball_x - bsize <= bat1_x + bat_w) AND
--           (ball_x + bsize >= bat1_x - bat_w) AND
--           (ball_y + bsize >= bat1_y - bat_h) AND
--           (ball_y - bsize <= bat1_y + bat_h) THEN
--            ball_x_motion <= ball_speed;
--        END IF;
        
--      --   Right bat collision
--        IF (ball_x + bsize >= bat2_x - bat_w) AND
--           (ball_x - bsize <= bat2_x + bat_w) AND
--           (ball_y + bsize >= bat2_y - bat_h) AND
--           (ball_y - bsize <= bat2_y + bat_h) THEN
--            ball_x_motion <= (NOT ball_speed) + 1;
--        END IF;
    -- UPDATED
    -- Left bat collision with random bounce
    IF (ball_x - bsize <= bat1_x + bat_w) AND
       (ball_x + bsize >= bat1_x - bat_w) AND
       (ball_y + bsize >= bat1_y - bat_h) AND
       (ball_y - bsize <= bat1_y + bat_h) THEN
        ball_x_motion <= ball_speed;
        IF random_bounce = '1' THEN
            CASE rand_value IS
                WHEN "000" => ball_y_motion <= (NOT (ball_speed - 2)) + 1;
                WHEN "001" => ball_y_motion <= ball_speed;
                WHEN "010" => ball_y_motion <= (NOT ball_speed) + 1;
                WHEN "011" => ball_y_motion <= (ball_speed - 2);
                WHEN "100" => ball_y_motion <= (NOT (ball_speed + 1)) + 1;
                WHEN OTHERS => ball_y_motion <= ball_speed;
            END CASE;
        END IF;
    END IF;
    
    -- Right bat collision with random bounce
    IF (ball_x + bsize >= bat2_x - bat_w) AND
       (ball_x - bsize <= bat2_x + bat_w) AND
       (ball_y + bsize >= bat2_y - bat_h) AND
       (ball_y - bsize <= bat2_y + bat_h) THEN
        ball_x_motion <= (NOT ball_speed) + 1;
        IF random_bounce = '1' THEN
            CASE rand_value IS
                WHEN "000" => ball_y_motion <= (NOT (ball_speed - 2)) + 1;
                WHEN "001" => ball_y_motion <= ball_speed;
                WHEN "010" => ball_y_motion <= (NOT ball_speed) + 1;
                WHEN "011" => ball_y_motion <= (ball_speed - 2);
                WHEN "100" => ball_y_motion <= (NOT (ball_speed + 1)) + 1;
                WHEN OTHERS => ball_y_motion <= ball_speed;
            END CASE;
        END IF;
    END IF;
            
--        -- compute next ball vertical position
--        -- variable temp adds one more bit to calculation to fix unsigned underflow problems
--        -- when ball_y is close to zero and ball_y_motion is negative
--        temp := ('0' & ball_y) + (ball_y_motion(10) & ball_y_motion);
--        IF game_on = '0' THEN
--            ball_y <= CONV_STD_LOGIC_VECTOR(440, 11);
--        ELSIF temp(11) = '1' THEN
--            ball_y <= (OTHERS => '0');
--        ELSE ball_y <= temp(10 DOWNTO 0); -- 9 downto 0
--        END IF;
--        -- compute next ball horizontal position
--        -- variable temp adds one more bit to calculation to fix unsigned underflow problems
--        -- when ball_x is close to zero and ball_x_motion is negative
--        temp := ('0' & ball_x) + (ball_x_motion(10) & ball_x_motion);
--        IF temp(11) = '1' THEN
--            ball_x <= (OTHERS => '0');
--        ELSE ball_x <= temp(10 DOWNTO 0);
--        END IF;

    -- ball logic now requires attention
    IF game_on = '1' THEN
            -- compute next ball vertical position
            -- variable temp adds one more bit to calculation to fix unsigned underflow problems
            -- when ball_y is close to zero and ball_y_motion is negative
            temp := ('0' & ball_y) + (ball_y_motion(10) & ball_y_motion);
            IF temp(11) = '1' THEN
                ball_y <= (OTHERS => '0');
            ELSE 
                ball_y <= temp(10 DOWNTO 0); -- 9 downto 0
            END IF;
            
            -- compute next ball horizontal position
            temp := ('0' & ball_x) + (ball_x_motion(10) & ball_x_motion);
            IF temp(11) = '1' THEN
                ball_x <= (OTHERS => '0');
            ELSE 
                ball_x <= temp(10 DOWNTO 0);
            END IF;
        END IF;
    END PROCESS;
END Behavioral;
