--------------------------------------------------------------------------------
--
--  File:
--      vga_struct.vhd
--
--  Authors:
--      Lorenzo Lazzara, Francesco Arnò, Andrea Manzini     
--
--------------------------------------------------------------------------------

--temp1 and temp2 values to set resolution
 
--vga temp1= "01010011000000011000001010000000"		0x53018280
--vga temp2= "00000010100001001111000000010000"		0x0284F010

--xga temp1=  "00011100010001010000010000000000"	0x1C450400
--xga temp2=  "00001110011101011000000000011000"	0x0E758018

--hd temp1= "00011010100001101100010100000000"		0x1A86C500
--hd temp2= "00110101010110010110100001001000"		0x35596848

--fhd temp1= "00100001011001001010011110000000"		0x2164A780
--fhd temp2= "00111101100100100001110001011000"		0x3D921C58

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_struct is
	port(
		reset: in std_logic;
		temp1: in std_logic_vector(31 downto 0); 
		temp2: in std_logic_vector(31 downto 0); 
		clock_vga: in std_logic;
		clock_xga: in std_logic;	
		clock_hd: in std_logic;
		clock_fhd: in std_logic;
		vga_r: out std_logic_vector(4 downto 0);
		vga_g: out std_logic_vector(5 downto 0);
		vga_b: out std_logic_vector(4 downto 0);
		vga_hs, vga_vs: out std_logic
	);	
end vga_struct;

architecture behav of vga_struct is

	signal h_count: std_logic_vector(11 downto 0);
	signal v_count: std_logic_vector(10 downto 0);
	signal video_on: std_logic;
	signal color_int: std_logic_vector(15 downto 0);
	signal h_total: std_logic_vector(11 downto 0);
	signal PULSE_POLARITY: std_logic;

	signal pix_clock: std_logic; 
	signal h_fporch:  std_logic_vector(6 downto 0);
	signal h_bporch:  std_logic_vector(7 downto 0);
	signal h_pulse:  std_logic_vector(7 downto 0);
	signal h_active:  std_logic_vector(10 downto 0);
	signal v_fporch:  std_logic_vector(3 downto 0);
	signal v_bporch:  std_logic_vector(5 downto 0);
	signal v_pulse:  std_logic_vector(2 downto 0);
	signal v_active:  std_logic_vector(10 downto 0);



	component vga_synch
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
			 h_total: out std_logic_vector(11 downto 0) 
		);
	end component;

	component vga_color
		port(
			ck,reset: in std_logic;
			video_on: in std_logic;
			v_count: in std_logic_vector(10 downto 0);
			h_count: in std_logic_vector(11 downto 0);
			pix_height: in std_logic_vector(10 downto 0);
			h_total: in std_logic_vector(11 downto 0);
			color: out std_logic_vector(15 downto 0)
		);
	end component;

	component sel_resolution
		port(
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
	end component;

	begin

		vga_r <= color_int(15 downto 11);
		vga_g <= color_int(10 downto 5);
		vga_b <= color_int(4 downto 0);

		sync: vga_synch
			port map(
				pix_clock => pix_clock,
				reset => reset,
				pulse_polarity => PULSE_POLARITY,
				vga_hs => vga_hs,
				vga_vs => vga_vs,
				video_on => video_on,
				h_counter => h_count,
				v_counter => v_count,
				h_total => h_total,
				h_active => h_active,
				h_bporch => h_bporch,
				h_fporch => h_fporch,
				h_pulse => h_pulse,
				v_active => v_active,
				v_bporch => v_bporch,
				v_fporch => v_fporch,
				v_pulse => v_pulse
			);

		pattern: vga_color
			port map(
				ck => pix_clock,
				reset => reset,
				video_on => video_on,
				h_count => h_count,
				v_count => v_count,
				pix_height => v_active,
				color => color_int,
				h_total => h_total
			);
		
		resolution: sel_resolution
			port map(
				temp1 => temp1,
				temp2 => temp2,
				clock_vga => clock_vga,
				clock_xga => clock_xga,
				clock_hd => clock_hd,
				clock_fhd => clock_fhd,
				pulse_polarity => PULSE_POLARITY,
				h_active => h_active,
				h_bporch => h_bporch,
				h_fporch => h_fporch,
				h_pulse => h_pulse,
				v_active => v_active,
				v_bporch => v_bporch,
				v_fporch => v_fporch,
				v_pulse => v_pulse,
				pix_clock => pix_clock
				
			);
	
end behav;
	
	
		
