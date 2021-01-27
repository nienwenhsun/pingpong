
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity test is
  Port (
 	rst			: in std_logic; 
  	clk			: in std_logic;
	button_add	: in std_logic; -- blink speed add
 	button_sub	: in std_logic; -- blink speed sub
 	led_order		: out std_logic_vector(6 downto 0); -- blink speed order
 	seg1			: out std_logic_vector(3 downto 0);
 	seg2			: out std_logic_vector(3 downto 0);
 	led_out		: out std_logic -- blink LED
 );
end test;

architecture Behavioral of test is

signal clk_1ms	: std_logic;						-- 1K Hz clk
signal tmp_1ms	: integer range 0 to 100000;
signal tmpclk		: std_logic;						-- div clk
signal tmp		: integer range 0 to 70000000;
signal th			: integer range 0 to 70000000;		-- clock change threshold
signal ledout		: std_logic;						-- led output
signal order		: std_logic_vector(6 downto 0);	-- speed order
signal button_count : integer range 0 to 100;			-- button debounce
signal button_flag 	: std_logic;						-- button status : 0 = release , 1 = press

signal num1		: std_logic_vector(3 downto 0);
signal num2		: std_logic_vector(3 downto 0);

begin

	led_order	<= order;
    led_out		<= ledout;
    seg1		<= num1;
    seg2		<= num2;
   
	speed: process(rst, button_flag, button_add, button_sub)
    begin
    	if rst = '1' then
    		th <= 35000000;
    	   	order <= "0001000";
    	elsif rising_edge(button_flag) then
			if button_add = '1' and order < "1000000"then
				order <= order(5 downto 0) & order(6);	-- LED left shift
				th <= th - 10000000;					-- speed add
			elsif button_sub = '1' and order > "0000001" then
				order <= order(0) & order(6 downto 1);	-- LED right shift
				th <= th + 10000000;					-- speed sub
			end if;
    	end if;
    end process;

	button: process(rst, clk_1ms, button_flag, button_add, button_sub)
    begin
    	if rst = '1' then
    		button_count <= 0;
    		button_flag <= '0';
    	elsif rising_edge(clk_1ms) then
    		if button_flag = '0' then
    			if button_add = '1' or button_sub = '1' then
    				button_count <= button_count + 1;
    				if button_count > 19 then -- button press stable
    					button_flag <= '1';
    					button_count <= 0;
    				end if;
    			end if; 		
    		elsif button_add = '0' and button_sub = '0' then -- button release
    			button_flag <= '0';
    		end if;
    	end if;   
    end process;
    
	blink: process(rst, tmpclk)
    begin
		if rst = '1' then
			ledout <= '0';
			num1 <= "0000";
			num2 <= "1001";
		elsif rising_edge(tmpclk) then
			ledout <= not ledout;
			num1 <= num1 + 1;
			num2 <= num2 - 1;
			
			if num1 > 8 then
				num1 <= "0000";
			end if;
			if num2 < 1 then
				num2 <= "1001";
			end if;
		end if;
    end process;
    
	divclk: process(rst, clk)
    begin
    	if rst = '1' then
    		tmp <= 0;
    		tmpclk <= '1';
    	elsif rising_edge(clk) then
    		tmp <= tmp + 1;
    		if tmp>th then
    			tmpclk <= not tmpclk;
    			tmp <= 0;
    		else
    			null;
    		end if;	
    	end if;
    end process;
    
    	clk1ms:	process(rst, clk)
    begin
    	if rst = '1' then
    		tmp_1ms <= 0;
    		clk_1ms <= '0';
    	elsif rising_edge(clk) then
    		tmp_1ms <= tmp_1ms + 1;
    		if tmp_1ms > 99999 then
    			clk_1ms <= not clk_1ms;
    			tmp_1ms <= 0;
    		else
    			null;
    		end if;	
    	end if;
    end process;

end Behavioral;
