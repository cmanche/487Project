-- BASED FROM FILE USED IN LAB, CHANGES ARE COMMENTED
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY pong IS
    PORT (
        clk_in : IN STD_LOGIC; -- system clock
        VGA_red : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- VGA outputs
        VGA_green : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_blue : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_hsync : OUT STD_LOGIC;
        VGA_vsync : OUT STD_LOGIC;
--      btnl : IN STD_LOGIC;
--      btnr : IN STD_LOGIC;
        -- CHANGE: Added buttons for both players
        btnl : IN STD_LOGIC; -- Player 1 up
        btnd : IN STD_LOGIC; -- Player 1 down
        btnu : IN STD_LOGIC; -- Player 2 up
        btnr : IN STD_LOGIC; -- Player 2 down
        btn0 : IN STD_LOGIC; -- serve
--      sw : IN STD_LOGIC_VECTOR(2 DOWNTO 0);  -- add switches for game mode ctrl
        sw : IN STD_LOGIC_VECTOR(15 DOWNTO 0);  -- extended to use more switches
        SEG7_anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- anodes of four 7-seg displays
        SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    ); 
END pong;

ARCHITECTURE Behavioral OF pong IS
    SIGNAL pxl_clk : STD_LOGIC := '0'; -- 25 MHz clock to VGA sync module
    -- internal signals to connect modules
    SIGNAL S_red, S_green, S_blue : STD_LOGIC; --_VECTOR (3 DOWNTO 0);
    SIGNAL S_vsync : STD_LOGIC;
    SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL batpos : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    SIGNAL count : STD_LOGIC_VECTOR (20 DOWNTO 0);
    SIGNAL display : std_logic_vector (15 DOWNTO 0); -- value to be displayed
    SIGNAL led_mpx : STD_LOGIC_VECTOR (2 DOWNTO 0); -- 7-seg multiplexing clock
    -- change: additional signal req
    SIGNAL bat1pos : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
    SIGNAL bat2pos : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
    -- CHANGE: Simplified display assignment for debugging
    SIGNAL score1, score2 : STD_LOGIC_VECTOR (3 DOWNTO 0);  
    CONSTANT bat_h : INTEGER := 50; -- match value from bat_n_ball.vhd
    COMPONENT bat_n_ball IS
        PORT (
            v_sync : IN STD_LOGIC;
            pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
 --         bat_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
            -- must be routed thru
            bat1_y : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- left bat y position
            bat2_y : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- right bat y position             
            serve : IN STD_LOGIC;
            red : OUT STD_LOGIC;
            green : OUT STD_LOGIC;
            blue : OUT STD_LOGIC;
            --mapped
            score1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            score2 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            speed_mode : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            -- CHANGE: add the new control ports to component
            invert_background : IN STD_LOGIC;
            invert_paddles : IN STD_LOGIC;
            random_bounce : IN STD_LOGIC
        );
    END COMPONENT;
    COMPONENT vga_sync IS
        PORT (
            pixel_clk : IN STD_LOGIC;
            red_in    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_in  : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_in   : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            red_out   : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_out  : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            hsync : OUT STD_LOGIC;
            vsync : OUT STD_LOGIC;
            pixel_row : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            pixel_col : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT clk_wiz_0 is
        PORT (
            clk_in1  : in std_logic;
            clk_out1 : out std_logic
        );
    END COMPONENT;
    COMPONENT leddec16 IS
        PORT (
            dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
        );
    END COMPONENT; 
    
BEGIN
--    pos : PROCESS (clk_in) is
--    BEGIN
--        if rising_edge(clk_in) then
--            count <= count + 1;
--            IF (btnl = '1' and count = 0 and batpos > 0) THEN
--                batpos <= batpos - 10;
--            ELSIF (btnr = '1' and count = 0 and batpos < 800) THEN
--                batpos <= batpos + 10;
--            END IF;
--        end if;
--    END PROCESS;

    -- must account for both bats now
    pos : PROCESS (clk_in)
    BEGIN
        IF rising_edge(clk_in) THEN
            count <= count + 1;
            -- player 1 (left) bat movement
            IF (btnl = '1' AND count = 0 AND bat1pos > bat_h) THEN
                bat1pos <= bat1pos - 10;
            ELSIF (btnd = '1' AND count = 0 AND bat1pos < 600 - bat_h) THEN
                bat1pos <= bat1pos + 10;
            END IF;
            
            -- player 2 (right) bat movement
            IF (btnu = '1' AND count = 0 AND bat2pos > bat_h) THEN
                bat2pos <= bat2pos - 10;
            ELSIF (btnr = '1' AND count = 0 AND bat2pos < 600 - bat_h) THEN
                bat2pos <= bat2pos + 10;
            END IF;
        END IF;
    END PROCESS;
    
    led_mpx <= count(19 DOWNTO 17); -- 7-seg multiplexing clock    
    add_bb : bat_n_ball
    PORT MAP(--instantiate bat and ball component
        v_sync => S_vsync, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
--      bat_x => batpos,
        bat1_y => bat1pos,
        bat2_y => bat2pos,
        serve => btn0,
        red => S_red,
        green => S_green,
        blue => S_blue,
        score1 => score1,
        score2 => score2,
        -- map sw to ball speed
        speed_mode => sw(2 DOWNTO 0),
        -- CHANGE:added new control mappings
        invert_background => sw(15),
        invert_paddles => sw(14),
        random_bounce => sw(13)
    );
    
    vga_driver : vga_sync
    PORT MAP(--instantiate vga_sync component
        pixel_clk => pxl_clk, 
        red_in => S_red & "000", 
        green_in => S_green & "000", 
        blue_in => S_blue & "000", 
        red_out => VGA_red, 
        green_out => VGA_green, 
        blue_out => VGA_blue, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        hsync => VGA_hsync, 
        vsync => S_vsync
    );
    VGA_vsync <= S_vsync; --connect output vsync
        
    clk_wiz_0_inst : clk_wiz_0
    port map (
      clk_in1 => clk_in,
      clk_out1 => pxl_clk
    );
    led1 : leddec16
    PORT MAP(
      dig => led_mpx, data => display, 
      anode => SEG7_anode, seg => SEG7_seg
    );
--  CHANGE: update display signal to show both scores
        -- played around with this a lot, but could quite get the digits to populate both 'halves' of 8 led's
        -- did our best though
--  display <= score2 & score1; -- Show both scores on 7-segment display
    display <= ("0000" & score1 & "0000" & score2);
--  display <= score2 & X"0" & score1 & X"0"; 

END Behavioral;
