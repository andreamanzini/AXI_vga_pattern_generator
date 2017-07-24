--------------------------------------------------------------------------------
--
--  File:
--      Colour_pattern_generator.vhd
--
--  Authors:
--      Lorenzo Lazzara, Francesco Arnò, Andrea Manzini
--      
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_color is
	port(
		ck: in std_logic;
		reset: in std_logic;
		video_on: in std_logic;
		v_count: in std_logic_vector(10 downto 0);
		h_count: in std_logic_vector(11 downto 0);
		pix_height: in std_logic_vector(10 downto 0); --vertical size of the screen. It's the signal v_active of sel_resolution
		h_total: in std_logic_vector(11 downto 0);
		color: out std_logic_vector(15 downto 0)
	);
end vga_color;
	
architecture behav of vga_color is 
	
	constant RED: std_logic_vector(15 downto 0) := "1111100000000000";
	constant GREEN: std_logic_vector(15 downto 0) := "0000011111100000";
	constant BLUE: std_logic_vector(15 downto 0) := "0000000000011111";
	constant WHITE: std_logic_vector(15 downto 0) := (others => '1');
	constant BLACK: std_logic_vector(15 downto 0) := (others => '0');
	constant YELLOW: std_logic_vector(15 downto 0) := "1111111111100000";
	constant VIOLET: std_logic_vector(15 downto 0) := "1111100000011111";
	constant AZURE: std_logic_vector(15 downto 0) := "0000011111111111";
	
	signal SLICE: integer;
	signal color_on: std_logic_vector(15 downto 0);
	
	begin 
	
		SLICE <= (to_integer(unsigned(pix_height))) / 8;
	
		color <= color_on when ( video_on='1') else (others=>'0');
	
		color_assign: process(ck,reset) 
		begin
			if reset='1' then 	
				color_on<= BLACK;
			elsif (rising_edge(ck) and h_count = h_total ) then
			
				if (unsigned(v_count) = SLICE - 1) then
					color_on <= RED;
				elsif (unsigned(v_count) = SLICE*2 - 1) then
					color_on <= GREEN;
				elsif (unsigned(v_count) = SLICE*3 - 1) then
					color_on <= BLUE;
				elsif (unsigned(v_count) = SLICE*4 - 1) then
					color_on <= VIOLET;
				elsif (unsigned(v_count) = SLICE*5 - 1) then
					color_on <= YELLOW;				
				elsif (unsigned(v_count) = SLICE*6 - 1) then
					color_on <= AZURE;
				elsif (unsigned(v_count) = SLICE*7 - 1) then
					color_on <= WHITE;
				elsif (unsigned(v_count) = SLICE*8 - 1) then
					color_on <= BLACK;
				end if;
			end if;
		end process color_assign;
	
end behav;
