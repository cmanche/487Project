LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity brick is
  Port (
      v_sync : IN STD_LOGIC;
      pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
      pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
      row_num : IN INTEGER RANGE 0 TO 7; -- row assignment for brick
      brick_x : IN STD_LOGIC_VECTOR(10 DOWNTO 0); --x position (variable)
      brick_y : IN STD_LOGIC_VECTOR(10 DOWNTO 0); -- y poistion (locked)
      in_play : IN STD_LOGIC; -- whether brick been hit or not
      brick_on : OUT STD_LOGIC -- birck display at pixel 
  );
end brick;

architecture Behavioral of brick is
    -- declaring crick dimensions
    CONSTANT brick_w : INTEGER := 50; -- width in pix
    CONSTANT brick_h : INTEGER := 20; -- heihgt in pix

begin
    -- pixel ofr brick logic
    draw_brick : PROCESS (pixel_row, pixel_col, brick_x, brick_y, in_play)
    BEGIN 
        IF (in_play = '1' AND 
            pixel_col >= brick_x AND pixel_col <= brick_x + brick_w AND 
            pixel_row >= brick_y AND pixel_row <= brick_y + brick_h) THEN 
            brick_on <= '1';
        ELSE 
            brick_on <= '0';
        END IF;
    END PROCESS;

end Behavioral;
