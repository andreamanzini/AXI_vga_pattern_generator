--------------------------------------------------------------------------------
--
--  File:
--      sel_resolution.vhd
--
--  Authors:
--      Lorenzo Lazzara, Francesco Arnò, Andrea Manzini
--
--------------------------------------------------------------------------------


Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity sel_resolution is 
	Port(
		temp1: in std_logic_vector(31 downto 0);
		temp2: in std_logic_vector(31 downto 0);
		clock_vga: in std_logic;
		clock_xga: in std_logic;
		clock_hd: in std_logic;
		clock_fhd: in std_logic;
		pix_clock: out std_logic;
		pulse_polarity: out std_logic;
		h_fporch: out std_logic_vector(6 downto 0);
		h_bporch: out std_logic_vector(7 downto 0);
		h_pulse: out std_logic_vector(7 downto 0);
		h_active: out std_logic_vector(10 downto 0);
		v_fporch: out std_logic_vector(3 downto 0);
		v_bporch: out std_logic_vector(5 downto 0);
		v_pulse: out std_logic_vector(2 downto 0);
		v_active: out std_logic_vector(10 downto 0)
	);
end sel_resolution;		
			
Architecture Behaviour of sel_resolution is

	begin 
		
		h_active <= temp1(10 downto 0);
		h_fporch <= temp2(6 downto 0);
		h_bporch <= temp1(18 downto 11);
		h_pulse <= temp1(26 downto 19);
		
		v_active <= temp2(17 downto 7);
		v_fporch <= temp1(30 downto 27);
		v_bporch <= temp2(23 downto 18);
		v_pulse  <= temp2(26 downto 24);
		
		pix_clock <= clock_vga when temp2(28 downto 27)="00" else
					 clock_xga when temp2(28 downto 27)="01" else 
					 clock_hd when temp2(28 downto 27)="10" else 
					 clock_fhd when temp2(28 downto 27)="11" else 
					 clock_vga;
		
		pulse_polarity <= temp2(29); -- Polarity resolution selection, negative for VGA and XGA, positive for HD and FULL HD
						
end Behaviour;