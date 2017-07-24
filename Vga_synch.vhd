--------------------------------------------------------------------------------
--
--  File:
--      Vga_synch.vhd
--
--  Authors:
--      Lorenzo Lazzara, Francesco Arnò, Andrea Manzini
--      
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_synch is
	port(
		 reset: in std_logic;
		 pix_clock: in std_logic;
		 pulse_polarity: in std_logic;
		 h_fporch: in std_logic_vector(6 downto 0);
		 h_bporch: in std_logic_vector(7 downto 0);
		 h_pulse: in std_logic_vector(7 downto 0);
		 h_active: in std_logic_vector(10 downto 0);
		 v_fporch: in std_logic_vector(3 downto 0);
		 v_bporch: in std_logic_vector(5 downto 0);
		 v_pulse: in std_logic_vector(2 downto 0);
		 v_active: in std_logic_vector(10 downto 0);
		 vga_hs, vga_vs: out std_logic;
		 video_on: out std_logic;
		 h_counter: out std_logic_vector(11 downto 0); -- MAX 2200(1080p resolution)
		 v_counter: out std_logic_vector(10 downto 0); -- MAX 1125(1080p resolution)
		 h_total: out std_logic_vector(11 downto 0) -- h_active + h_fporch + h_fporch + h_pulse
		 );
	end vga_synch;

architecture behav of vga_synch is

	signal HD: integer; -- horizontal display
	signal HF: integer; -- hsync front porch
	signal HB: integer; -- hsync back porch
	signal HP: integer; -- hsync pulse

	signal VD: integer; -- vertical display
	signal VF: integer; -- vsync front porch
	signal VB: integer; -- vsync back porch
	signal VP: integer; -- vsync pulse

	signal videoh_on: std_logic:='1';
	signal videov_on: std_logic:='1';

	begin
		
		HD <= to_integer(unsigned(h_active));
		HF <= to_integer(unsigned(h_fporch));
		HB <= to_integer(unsigned(h_bporch));
		HP <= to_integer(unsigned(h_pulse));
		
		VD <= to_integer(unsigned(v_active));
		VF <= to_integer(unsigned(v_fporch));
		VB <= to_integer(unsigned(v_bporch));
		VP <= to_integer(unsigned(v_pulse));
		
		h_total<= std_logic_vector(to_unsigned(to_integer(unsigned(h_active)+unsigned(h_bporch)+unsigned(h_fporch)+unsigned(h_pulse))- 1,12)); -- "-1" because h_counter starts from 0
		
		video_on <= (videoh_on and videov_on);
		
		gen_hsynch: process(pix_clock, reset)
					begin
							if reset='1' then
								h_counter <= (others => '0');
								videoh_on <= '1';
								vga_hs <= not pulse_polarity; 
							
							elsif rising_edge(pix_clock) then
							
								if (unsigned(h_counter) = HD - 1) then	--(HD-1) perché assegnazione effettuata al ciclo successivo (simulato)
									videoh_on <= '0';
								elsif (unsigned(h_counter) = HD+HB+HF+HP - 1) then
									videoh_on <= '1';
								end if;
									
								if ((unsigned(h_counter) >= (HD+HF) - 1) and (unsigned(h_counter) < (HD+HF+HP) - 1)) then
									vga_hs <= pulse_polarity;
								else
									vga_hs <= not pulse_polarity;
								end if;
									
								if unsigned(h_counter) = (HD+HF+HB+HP)-1 then
									h_counter <= (others => '0');
								else
									h_counter <= std_logic_vector(unsigned(h_counter) + 1);
								end if;
							end if;
					end process gen_hsynch;
					
		gen_vsynch: process(pix_clock, reset)
					begin
							if reset='1' then
								v_counter <= (others => '0');
								videov_on <= '1';
								vga_vs <= not pulse_polarity; --'1';
							elsif (rising_edge(pix_clock) and unsigned(h_counter) = (HD+HF+HB+HP)-1) then
							
								if (unsigned(v_counter) = VD - 1) then
									videov_on <= '0';
								elsif (unsigned(v_counter) = VD+VF+VB+VP - 1) then
									videov_on <= '1';
								end if;
									
								if (unsigned(v_counter) >= (VD+VF)) and (unsigned(v_counter) < (VD+VF+VP)) then
									vga_vs <= pulse_polarity; --'0';
								else
									vga_vs <= not pulse_polarity; --'1'; 
								end if;
									
								if unsigned(v_counter) = (VD+VF+VB+VP)-1 then
									v_counter <= (others => '0');
								else
									v_counter <= std_logic_vector(unsigned(v_counter) + 1);
								end if;
							end if;
					end process gen_vsynch;
				
end behav;
	
								
							


