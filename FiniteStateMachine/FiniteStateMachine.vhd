LIBRARY ieee; --standard library
USE IEEE.STD_LOGIC_1164.ALL; --use sublibrary
USE IEEE.STD_LOGIC_UNSIGNED.ALL; --use sublibrary
USE IEEE.NUMERIC_STD.ALL; --use sublibrary

ENTITY FiniteStateMachine IS --entity declaration
	PORT( --port declaration
		clock							:	IN	STD_LOGIC_VECTOR(1 DOWNTO 0); --clock input
		enable, reset, display			:	IN	STD_LOGIC; --enable, reset, display inputs
		SEG0, SEG1, SEG2,SEG3			:	OUT STD_LOGIC_VECTOR(0 TO 6); --7-segment display outputs
		LED_en, LED_rst, LED_display	:	OUT STD_LOGIC; --enable, reset, display outputs LEDs
		LED_seconds						:	OUT STD_LOGIC_VECTOR(9 downto 0); --clock LED
		LED_stage						:	OUT STD_LOGIC_VECTOR(3 DOWNTO 0); --stage LED
		VGA_HS, VGA_VS					:	OUT	STD_LOGIC; --VGA horizontal, vertical outputs
		VGA_R, VGA_G, VGA_B				:	BUFFER STD_LOGIC_VECTOR(3 DOWNTO 0) --VGA RGB
		);
END FiniteStateMachine; --end entity declaration

ARCHITECTURE FiniteStateMachine OF FiniteStateMachine IS --architecture declaration
	CONSTANT C_LOGIC : BOOLEAN := FALSE; --7-segment display logic: TRUE=Active HIGH,FALSE=Active LOW
	CONSTANT C_CLOCK : INTEGER := 24000000; --clock frequency
	TYPE state_type IS (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15); --state declaration
	SIGNAL state_current, state_next : state_type; --current and next state declaration
	SIGNAL stage : INTEGER; --state output
	SIGNAL stage_vector : STD_LOGIC_VECTOR(3 DOWNTO 0); --state output
	SIGNAL clock_cycles : INTEGER RANGE 0 TO 1000000000; --clock cycle count
	TYPE t_array IS ARRAY (0 TO 3) OF INTEGER; --output declaration
	SIGNAL outputs : t_array := (67, 83, 67, 73); --output
	SIGNAL seconds : INTEGER RANGE 0 TO 2**10 - 1; --seconds
	SIGNAL VGACLK : STD_LOGIC :='0'; --VGA CLOCK
	SIGNAL VGARESET : STD_LOGIC :='0'; --VGA RESET

	COMPONENT PLL IS --PLL component
		PORT( --port declaration
			inclk0 : IN STD_LOGIC := 'X'; --CLK IN
			RESET : IN STD_LOGIC := 'X'; --RESET
			C0 : OUT STD_LOGIC --CLK OUT
		);
	END COMPONENT PLL; --end component
	
	COMPONENT SYNC IS --sync componenet
		PORT( --port declasration
			CLK : IN STD_LOGIC; --clk
			HSYNC, VSYNC : OUT STD_LOGIC; --hsync, vsync
			R, G, B : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); --RGB output
			S : IN STD_LOGIC_VECTOR(3 DOWNTO 0) --input
		);
	END COMPONENT SYNC; -- end component

	FUNCTION vector(number : INTEGER; logic: BOOLEAN) --function declaration (int to SLV)
		RETURN STD_LOGIC_VECTOR IS --return an STD_LOGIC_VECTOR
			VARIABLE vector_val : STD_LOGIC_VECTOR(0 TO 6) := "0000000"; --variable declaration
	BEGIN --begin function
		CASE number IS --check input
			WHEN 0 => -- when input is 0
				IF logic THEN -- if active HIGH
					vector_val := "1111110"; -- "0"
				ELSE --if active LOW
					vector_val := "0000001"; -- "0"
				END IF; --end if
			WHEN 1 => -- when input is 1
				IF logic THEN -- if active HIGH
					vector_val := "0110000"; -- "1" 
				ELSE --if active LOW
					vector_val := "1001111"; -- "1"
				END IF; --end if
			WHEN 2 => -- when input is 2
				IF logic THEN -- if active HIGH
					vector_val := "1101101"; -- "2" 
				ELSE --if active LOW
					vector_val := "0010010"; -- "2"
				END IF; --end if
			WHEN 3 => -- when input is 3
				IF logic THEN -- if active HIGH
					vector_val := "1111001"; -- "3" 
				ELSE --if active LOW
					vector_val := "0000110"; -- "3"
				END IF; --end if
			WHEN 4 => -- when input is 4
				IF logic THEN -- if active HIGH
					vector_val := "0110011"; -- "4" 
				ELSE --if active LOW
					vector_val := "1001100"; -- "4"
				END IF; --end if
			WHEN 5 => -- when input is 5
				IF logic THEN -- if active HIGH
					vector_val := "1011011"; -- "5" 
				ELSE --if active LOW
					vector_val := "0100100"; -- "5"
				END IF; --end if
			WHEN 6 => -- when input is 6
				IF logic THEN -- if active HIGH
					vector_val := "1011111"; -- "6" 
				ELSE --if active LOW
					vector_val := "0100000"; -- "6"
				END IF; --end if
			WHEN 7 => -- when input is 7
				IF logic THEN -- if active HIGH
					vector_val := "1110000"; -- "7" 
				ELSE --if active LOW
					vector_val := "0001111"; -- "7"
				END IF; --end if
			WHEN 8 => -- when input is 8
				IF logic THEN -- if active HIGH
					vector_val := "1111111"; -- "8"     
				ELSE --if active LOW
					vector_val := "0000000"; -- "8"
				END IF; --end if
			WHEN 9 => -- when input is 9
				IF logic THEN -- if active HIGH
					vector_val := "1110011"; -- "9" 
				ELSE --if active LOW
					vector_val := "0001100"; -- "9"
				END IF; --end if
			WHEN 45 => -- when input is -
				IF logic THEN -- if active HIGH
					vector_val := "0000001"; -- "-" 
				ELSE --if active LOW
					vector_val := "1111110"; -- "-"
				END IF; --end if
			WHEN 67 => -- when input is C
				IF logic THEN -- if active HIGH
					vector_val := "1001110"; -- "C" 
				ELSE --if active LOW
					vector_val := "0110001"; -- "C"
				END IF; --end if
			WHEN 68 => -- when input is d
				IF logic THEN -- if active HIGH
					vector_val := "0111101"; -- "D"
				ELSE --if active LOW
					vector_val := "1000010"; -- "D"
				END IF; --end if
			WHEN 69 => -- when input is E
				IF logic THEN -- if active HIGH
					vector_val := "1001111"; -- "E"
				ELSE --if active LOW
					vector_val := "0110000"; -- "E"
				END IF; --end if
			WHEN 71 => -- when input is G
				IF logic THEN -- if active HIGH
					vector_val := "1011111"; -- "G" 
				ELSE --if active LOW
					vector_val := "0100000"; -- "G"
				END IF; --end if
			WHEN 73 => -- when input is I
				IF logic THEN -- if active HIGH
					vector_val := "0110000"; -- "I" 
				ELSE --if active LOW
					vector_val := "1001111"; -- "I"
				END IF; --end if
			WHEN 76 => -- when input is L
				IF logic THEN -- if active HIGH
					vector_val := "0001110"; -- "L" 
				ELSE --if active LOW
					vector_val := "1110001"; -- "L"
				END IF; --end if
			WHEN 78 => -- when input is n
				IF logic THEN -- if active HIGH
					vector_val := "0010101"; -- "N" 
				ELSE --if active LOW
					vector_val := "1101010"; -- "N"
				END IF; --end if
			WHEN 83 => -- when input is S
				IF logic THEN -- if active HIGH
					vector_val := "1011011"; -- "S" 
				ELSE --if active LOW
					vector_val := "0100100"; -- "S"
				END IF; --end if
			WHEN 86 => -- when input is V
				IF logic THEN -- if active HIGH
					vector_val := "0111110"; -- "V" 
				ELSE --if active LOW
					vector_val := "1000001"; -- "V"
				END IF; --end if
			WHEN 255 => -- when input is  
				IF logic THEN -- if active HIGH
					vector_val := "0000000"; -- " " 
				ELSE --if active LOW
					vector_val := "1111111"; -- " "
				END IF; --end if
			WHEN OTHERS => -- when input is 
				IF logic THEN -- if active HIGH
					vector_val := "0000000"; -- " " 
				ELSE --if active LOW
					vector_val := "1111111"; -- " "
				END IF; --end if
		END CASE; --end case
		RETURN vector_val; --return value
	END FUNCTION; --end function
BEGIN --begin architecture
	STATE: PROCESS(state_current, enable, reset) --state process
	BEGIN --begin process
		CASE state_current IS --check current state
			WHEN S0 => --when state is S0
				stage <= 0; --0
				outputs <= (67, 83, 67, 73); --CSCI
				IF (enable = '1') THEN --if enabled
					state_next <= S1; --assign next state
				ELSE --if not enabled
					state_next <= state_current; --next state is current state
				END IF; --end if
			WHEN S1 => --when state is S1
				stage <= 1; --1
				outputs <= (83, 67, 73, 6); --SCI6
				IF (enable = '1') THEN --if enabled
					state_next <= S2; --assign next state
				ELSE --if not enabled
					state_next <= state_current; --next state is current state
				END IF; --end if
			WHEN S2 => --when state is S2
				stage <= 2; --2
				outputs <= (67, 73, 6, 6); --CI66
				IF (enable = '1') THEN --if enabled
					state_next <= S3; --assign next state
				ELSE --if not enabled
					state_next <= state_current; --next state is current state
				END IF; --end if
			WHEN S3 => --when state is S3
				stage <= 3; --3
				outputs <= (73, 6, 6, 0); --I660
				IF (enable = '1') THEN --if enabled
					state_next <= S4; --assign next state
				ELSE --if not enabled
					state_next <= state_current; --next state is current state
				END IF; --end if
			WHEN S4 => --when state is S4
				stage <= 4; --4
				outputs <= (6, 6, 0, 45); --660-
				IF (enable = '1') THEN --if enabled
					state_next <= S5; --assign next state
				ELSE --if not enabled
					state_next <= state_current; --next state is current state
				END IF; --end if
			WHEN S5 => --when state is S5
				stage <= 5; --5
				outputs <= (6, 0, 45, 86); --60-V
				IF (enable = '1') THEN --if enabled
					state_next <= S6; --assign next state
				ELSE --if not enabled
					state_next <= state_current; --next state is current state
				END IF; --end if
			WHEN S6 => --when state is S6
				stage <= 6; --6
				outputs <= (0, 45, 86, 76); --0-VL
				IF (enable = '1') THEN --if enabled
					state_next <= S7; --assign next state
				ELSE --if not enabled
					state_next <= state_current; --next state is current state
				END IF; --end if
			WHEN S7 => --when state is S7
				stage <= 7; --7
				outputs <= (45, 86, 76, 83); ---VLS
				IF (enable = '1') THEN --if enabled
					state_next <= S8; --assign next state
				ELSE --if not enabled
					state_next <= state_current; --next state is current state
				END IF; --end if
			WHEN S8 => --when state is S8
				stage <= 8; --8
				outputs <= (86, 76, 83, 73); --VLSI
				IF (enable = '1') THEN --if enabled
					state_next <= S9; --assign next state
				ELSE --if not enabled
					state_next <= state_current; --next state is current state
				END IF; --end if
			WHEN S9 => --when state is S9
				stage <= 9; --9
				outputs <= (76, 83, 73, 255); --LSI 
				IF (enable = '1') THEN --if enabled
					state_next <= S10; --assign next state
				ELSE --if not enabled
					state_next <= state_current; --next state is current state
				END IF; --end if
			WHEN S10 => --when state is S10
				stage <= 10; --10
				outputs <= (83, 73, 255, 68); --SI D
				IF (enable = '1') THEN --if enabled
					state_next <= S11; --assign next state
				ELSE --if not enabled
					state_next <= state_current; --next state is current state
				END IF; --end if
			WHEN S11 => --when state is S11
				stage <= 11; --11
				outputs <= (73, 255, 68, 69); --I DE
				IF (enable = '1') THEN --if enabled
					state_next <= S12; --assign next state
				ELSE --if not enabled
					state_next <= state_current; --next state is current state
				END IF; --end if
			WHEN S12 => --when state is S12
				stage <= 12; --12
				outputs <= (255, 68, 69, 83); -- DES
				IF (enable = '1') THEN --if enabled
					state_next <= S13; --assign next state
				ELSE --if not enabled
					state_next <= state_current; --next state is current state
				END IF; --end if
			WHEN S13 => --when state is S13
				stage <= 13; --13
				outputs <= (68, 69, 83, 73); --DESI
				IF (enable = '1') THEN --if enabled
					state_next <= S14; --assign next state
				ELSE --if not enabled
					state_next <= state_current; --next state is current state
				END IF; --end if
			WHEN S14 => --when state is S14
				stage <= 14; --14
				outputs <= (69, 83, 73, 71); --ESIG
				IF (enable = '1') THEN --if enabled
					state_next <= S15; --assign next state
				ELSE --if not enabled
					state_next <= state_current; --next state is current state
				END IF; --end if
			WHEN S15 => --when state is S15
				stage <= 15; --15
				outputs <= (83, 73, 71, 78); --SIGN
				IF (enable = '1') THEN --if enabled
					state_next <= S0; --assign next state
				ELSE --if not enabled
					state_next <= state_current; --next state is current state
				END IF; --end if
		END CASE; --end case
	END PROCESS; --end process
	
	SYNCH: PROCESS --flip-flop generation
	BEGIN --begin process
		WAIT UNTIL RISING_EDGE(clock(1)); --on pos edge clock
		IF (clock_cycles >= c_clock) THEN --after 1 second
			clock_cycles <= 0; --reset clock_cycles
			seconds <= seconds + 1; --increase time
			IF (reset = '1') THEN --if reset
				state_current <= S0; --default state
			ELSE --if not reset
				state_current <= state_next; --move to next state
			END IF; --end if
		ELSE --if not after 1 second
			clock_cycles <= clock_cycles + 1; --increment clock_cycles
		END IF; --end if
	END PROCESS; --end process
	
	LEDS: PROCESS(enable, reset, display, seconds, stage, outputs) --output process
		VARIABLE temp0, temp1, temp2, temp3 : STD_LOGIC_VECTOR(0 to 6); --temp variables
	BEGIN --begin process
		LED_en <= enable; --enable LED
		LED_rst <= reset; --reset LED
		LED_display <= display; --display LED
		IF (display = '1') THEN --if display
			temp3 := vector(outputs(0), C_LOGIC); --HEX3 output
			temp2 := vector(outputs(1), C_LOGIC); --HEX2 output
			temp1 := vector(outputs(2), C_LOGIC); --HEX1 output
			temp0 := vector(outputs(3), C_LOGIC); --HEX0 output
		ELSE --if not display
			temp3 := vector((seconds / 10) REM 10, C_LOGIC); --seconds tens digit
			temp2 := vector(seconds REM 10, C_LOGIC); --seconds ones digit
			temp1 := vector(stage / 10, C_LOGIC); --stage tens digit
			temp0 := vector(stage REM 10, C_LOGIC); --stage ones digit
		END IF; --end if
		FOR i IN 0 TO 6 LOOP --loop 6 times
			SEG3(i) <= temp3(i); --HEX3
			SEG2(i) <= temp2(i); --HEX2
			SEG1(i) <= temp1(i); --HEX1
			SEG0(i) <= temp0(i); --HEX0
		END LOOP; --end loop
		LED_seconds <= STD_LOGIC_VECTOR(to_unsigned(seconds,LED_seconds'length)); --LEDR
		LED_stage <= std_logic_vector(to_unsigned(stage, LED_stage'length)); --LEDG
	END PROCESS; --end process
	
	stage_vector <= STD_LOGIC_VECTOR(TO_UNSIGNED(stage, stage_vector'LENGTH)); --stage
	
	C1: SYNC PORT MAP(VGACLK,VGA_HS,VGA_VS,VGA_R,VGA_G,VGA_B,stage_vector); --SYNC port map
	C2: PLL PORT MAP(clock(0),VGARESET,VGACLK); --PLL port map

END FiniteStateMachine; --end architecture
