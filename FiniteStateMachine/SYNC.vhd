LIBRARY IEEE; -- Standard library
USE IEEE.STD_LOGIC_1164.ALL; -- Use sublibrary
USE IEEE.NUMERIC_STD.ALL; -- Use sublibrary
USE IEEE.STD_LOGIC_UNSIGNED.ALL; -- Use sublibrary

ENTITY SYNC IS -- Entity Initialization
	GENERIC(
		H_PIXELS	:INTEGER:=	1280; -- Visible horizontal pixels on screen
		H_FP	:	INTEGER	:=	48;   -- Horizontal front porch
		H_BP	:	INTEGER	:=	248;  -- Horizontal back porch
		H_SYNC	:	INTEGER	:=	112;  -- Horizontal sync
		V_PIXELS:	INTEGER	:=	1024; -- Visible vertial pixels on screen
		V_FP	:	INTEGER	:=	1;    -- Vertical front porch
		V_BP	:	INTEGER	:=	38;   -- Vertical back porch
		V_SYNC	:	INTEGER	:=	3     -- Vertical sync
	);
	PORT( -- Portal Initialization
		Clk				:	IN STD_LOGIC; --Clock input on VGA connection
		HSYNC, VSYNC	:	OUT STD_LOGIC; -- Horizontal and Vertical Sync Outputs on VGA connection
		R, G, B			:	OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- Red, Green, Blue Outputs on VGA connection
		S				:	IN STD_LOGIC_VECTOR(3 DOWNTO 0) -- Input Switches 0 to 4 on Altera DE1
	);
END ENTITY SYNC; -- Entity ended

ARCHITECTURE MAIN of SYNC IS -- Architecture Initialization
	-- 1280x1024 resolution setting for a 60 Hz VGA Display Monitor 
	-- Pixel Clock is 108 MHz for the sync components to control all VGA signals
	SIGNAL HPOS : INTEGER RANGE 0 TO H_PIXELS + H_FP + H_BP + H_SYNC; --horizontal pixels
	SIGNAL VPOS : INTEGER RANGE 0 TO V_PIXELS + V_FP + V_BP + V_SYNC; -- verical pixels
	CONSTANT H_OFFSET:	INTEGER	:=	H_FP + H_BP + H_SYNC; -- Offset constant for horizontal pixels
	CONSTANT V_OFFSET:	INTEGER	:=	V_FP + V_BP + V_SYNC; -- Offset constant for vertical pixels
BEGIN 
	PROCESS(CLK) --Begin process using clock
	BEGIN 
		IF RISING_EDGE(clk) THEN -- Each clock increases HPOS by 1, and once it hits the END of the line will reset back to 0
			IF (S = X"0") THEN -- If in state 0 then display a blue square in this portion of the screen
				IF((HPOS > H_OFFSET) AND (HPOS < (H_OFFSET + (H_PIXELS / 4)))
					AND (VPOS > V_OFFSET) AND (VPOS < (V_OFFSET + (V_PIXELS / 4)))) THEN
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'0'); -- Green = 0
					B<=(OTHERS=>'1'); -- Blue = 1
				ELSE -- If no longer in state 0 then display a black color in this portion of the screen
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'0'); -- Green = 0
					B<=(OTHERS=>'0'); -- Blue = 0
				END IF; -- End inner If
			END IF;  -- End If
			IF (S = X"1") THEN -- If in state 1 then display a green square in this portion of the screen
				IF((HPOS > H_OFFSET + (H_PIXELS / 4)) AND (HPOS < (H_OFFSET + (H_PIXELS / 2)))
					AND (VPOS > V_OFFSET) AND (VPOS < (V_OFFSET + (V_PIXELS / 4)))) THEN
					R<=(OTHERS=>'0');  -- Red = 0
					G<=(OTHERS=>'1');  -- Green = 1
					B<=(OTHERS=>'0');  -- Blue = 0
				ELSE -- If no longer in state 1 then display a black color in this portion of the screen
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'0'); -- Green = 0
					B<=(OTHERS=>'0'); -- Blue = 0
				END IF; -- End inner If
			END IF;  -- End If
			IF (S = X"2") THEN -- If in state 2 then display a red square in this portion of the screen
				IF((HPOS > (H_OFFSET + (H_PIXELS / 2))) AND (HPOS < (H_OFFSET + (3 *(H_PIXELS / 4))))
					AND (VPOS > V_OFFSET) AND (VPOS < (V_OFFSET + (V_PIXELS / 4)))) THEN
					R<=(OTHERS=>'1'); -- Red = 1
					G<=(OTHERS=>'0'); -- Green = 0
					B<=(OTHERS=>'0'); -- Blue = 0
				ELSE -- If no longer in state 2 then display a black color in this portion of the screen
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'0'); -- Green = 0
					B<=(OTHERS=>'0'); -- Blue = 0
				END IF; -- End inner If
			END IF; -- End If
            IF (S = X"3") THEN -- If in state 3 then display a cyan square in this portion of the screen
				IF((HPOS > (H_OFFSET + (3 *(H_PIXELS / 4)))) AND (HPOS < H_PIXELS + H_OFFSET)
					AND (VPOS > V_OFFSET) AND (VPOS < (V_OFFSET + (V_PIXELS / 4)))) THEN
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'1'); -- Green = 1
					B<=(OTHERS=>'1'); -- Blue = 1
				ELSE -- If no longer in state 3 then display a black color in this portion of the screen
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'0'); -- Green = 0
					B<=(OTHERS=>'0'); -- Blue = 0
				END IF; -- End inner If
			END IF; -- End If
			IF (S = X"4") THEN -- If in state 4 then display a magneta square in this portion of the screen
				IF((HPOS > H_OFFSET) AND (HPOS < (H_OFFSET + (H_PIXELS / 4)))
					AND (VPOS > (V_OFFSET + (V_PIXELS / 4))) AND (VPOS < (V_OFFSET + (V_PIXELS / 2)))) THEN
					R<=(OTHERS=>'1');
					G<=(OTHERS=>'0');
					B<=(OTHERS=>'1');
				ELSE -- If no longer in state 4 then display a black color in this portion of the screen
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'0'); -- Green = 0
					B<=(OTHERS=>'0'); -- Blue = 0
				END IF; -- End inner If
			END IF; -- End If
			IF (S = X"5") THEN -- If in state 5 then display a yellow square in this portion of the screen
				IF((HPOS > (H_OFFSET + (H_PIXELS / 4))) AND (HPOS < (H_OFFSET + (H_PIXELS / 2)))
					AND (VPOS > (V_OFFSET + (V_PIXELS / 4))) AND (VPOS < (V_OFFSET + (V_PIXELS / 2)))) THEN
					R<=(OTHERS=>'1'); -- Red = 1
					G<=(OTHERS=>'1'); -- Green = 1
					B<=(OTHERS=>'0'); -- Blue = 0
				ELSE -- If no longer in state 5 then display a black color in this portion of the screen
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'0'); -- Green = 0
					B<=(OTHERS=>'0'); -- Blue = 0
				END IF; -- End inner If
			END IF; -- End If
			IF (S = X"6") THEN -- If in state 6 then display a white square in this portion of the screen
				IF((HPOS > (H_OFFSET + (H_PIXELS / 2))) AND (HPOS < (H_OFFSET + (3 *(H_PIXELS / 4))))
					AND (VPOS > (V_OFFSET + (V_PIXELS / 4))) AND (VPOS < (V_OFFSET + (V_PIXELS / 2)))) THEN
					R<=(OTHERS=>'1'); -- Red = 1
					G<=(OTHERS=>'1'); -- Green = 1
					B<=(OTHERS=>'1'); -- Blue = 1
				ELSE -- If no longer in state 6 then display a black color in this portion of the screen
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'0'); -- Green = 0
					B<=(OTHERS=>'0'); -- Blue = 0
				END IF; -- End inner If
			END IF;  -- End If
			IF (S = X"7") THEN -- If in state 7 then display a blue square in this portion of the screen
				IF((HPOS > (H_OFFSET + (3 *(H_PIXELS / 4)))) AND (HPOS < (H_OFFSET + H_PIXELS))
					AND (VPOS > (V_OFFSET + (V_PIXELS / 4))) AND (VPOS < (V_OFFSET + (V_PIXELS / 2)))) THEN
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'0'); -- Green = 0 
					B<=(OTHERS=>'1'); -- Blue = 1
				ELSE -- If no longer in state 7 then display a black color in this portion of the screen
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'0'); -- Green = 0
					B<=(OTHERS=>'0'); -- Blue = 0
				END IF; -- End inner If
			END IF; -- End If   
			IF (S = X"8") THEN -- If in state 8 then display a green square in this portion of the screen
				IF((HPOS > H_OFFSET) AND (HPOS < (H_OFFSET + (H_PIXELS / 4)))
					AND (VPOS > (V_OFFSET + (V_PIXELS / 2))) AND (VPOS < (V_OFFSET + (3 * V_PIXELS / 4)))) THEN
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'1'); -- Green = 1
					B<=(OTHERS=>'0'); -- Blue = 0
				ELSE -- If no longer in state 8 then display a black color in this portion of the screen
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'0'); -- Green = 0
					B<=(OTHERS=>'0'); -- Blue = 0
				END IF; -- End inner If
			END IF; -- End If 
			IF (S = X"9") THEN -- If in state 9 then display a red square in this portion of the screen
				IF((HPOS > (H_OFFSET + (H_PIXELS / 4))) AND (HPOS < (H_OFFSET + (H_PIXELS / 2)))
					AND (VPOS > (V_OFFSET + (V_PIXELS / 2))) AND (VPOS < (V_OFFSET + (3 * V_PIXELS / 4)))) THEN
					R<=(OTHERS=>'1'); -- Red = 1
					G<=(OTHERS=>'0'); -- Green = 0
					B<=(OTHERS=>'0'); -- Blue = 0
				ELSE -- If no longer in state 9 then display a black color in this portion of the screen
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'0'); -- Green = 0
					B<=(OTHERS=>'0'); -- Blue = 0
				END IF; -- End inner If
			END IF;  -- End If 
			IF (S = X"A") THEN -- If in state 10 then display a cyan square in this portion of the screen
				IF((HPOS > (H_OFFSET + (H_PIXELS / 2))) AND (HPOS < (H_OFFSET + (3 * H_PIXELS / 4)))
					AND (VPOS > (V_OFFSET + (V_PIXELS / 2))) AND (VPOS < (V_OFFSET + (3 * V_PIXELS / 4)))) THEN
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'1'); -- Green = 1
					B<=(OTHERS=>'1'); -- Blue = 1
				ELSE -- If no longer in state 10 then display a black color in this portion of the screen
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'0'); -- Green = 0
					B<=(OTHERS=>'0'); -- Blue = 0
				END IF; -- End inner If
			END IF; -- End If 
			IF (S = X"B") THEN -- If in state 11 then display a magneta square in this portion of the screen
				IF((HPOS > (H_OFFSET + (3 * H_PIXELS / 4))) AND (HPOS < (H_OFFSET + H_PIXELS))
					AND (VPOS > (V_OFFSET + (V_PIXELS / 2))) AND (VPOS < (V_OFFSET + (3 * V_PIXELS / 4)))) THEN
					R<=(OTHERS=>'1'); -- Red = 1
					G<=(OTHERS=>'0'); -- Green = 0
					B<=(OTHERS=>'1'); -- Blue = 1
				ELSE -- If no longer in state 11 then display a black color in this portion of the screen
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'0'); -- Green = 0
					B<=(OTHERS=>'0'); -- Blue = 0
				END IF; -- End inner If
			END IF;  -- End If 
			IF (S = X"C") THEN -- If in state 12 then display a yellow square in this portion of the screen
				IF((HPOS > (H_OFFSET)) AND (HPOS < (H_OFFSET + (H_PIXELS / 4)))
					AND (VPOS > (V_OFFSET + (3 * V_PIXELS / 4))) AND (VPOS < (V_OFFSET + V_PIXELS))) THEN
					R<=(OTHERS=>'1'); -- Red = 1
					G<=(OTHERS=>'1'); -- Green = 1
					B<=(OTHERS=>'0'); -- Blue = 0
				ELSE -- If no longer in state 12 then display a black color in this portion of the screen
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'0'); -- Green = 0
					B<=(OTHERS=>'0'); -- Blue = 0
				END IF;  -- End inner If
			END IF; -- End If 
			IF (S = X"D") THEN -- If in state 13 then display a white square in this portion of the screen
				IF((HPOS > (H_OFFSET + (H_PIXELS / 4))) AND (HPOS < (H_OFFSET + (H_PIXELS / 2)))
					AND (VPOS > (V_OFFSET + (3 * V_PIXELS / 4))) AND (VPOS < (V_OFFSET + V_PIXELS))) THEN
					R<=(OTHERS=>'1'); -- Red = 1
					G<=(OTHERS=>'1'); -- Blue = 1
					B<=(OTHERS=>'1'); -- Green = 1
				ELSE -- If no longer in state 13 then display a black color in this portion of the screen
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'0'); -- Green = 0
					B<=(OTHERS=>'0'); -- Blue = 0
				END IF; -- End inner If
			END IF; -- End If  
			IF (S = X"E") THEN -- If in state 14 then display a blue square in this portion of the screen
				IF((HPOS > (H_OFFSET + (H_PIXELS / 2))) AND (HPOS < (H_OFFSET + (3 * H_PIXELS / 4)))
					AND (VPOS > (V_OFFSET + (3 * V_PIXELS / 4))) AND (VPOS < (V_OFFSET + V_PIXELS))) THEN
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'0'); -- Green = 0
					B<=(OTHERS=>'1'); -- Blue = 1
				ELSE -- If no longer in state 14 then display a black color in this portion of the screen
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'0'); -- Green = 0
					B<=(OTHERS=>'0'); -- Blue = 0
				END IF; -- End inner If
			END IF; -- End If  
			IF (S = X"F") THEN -- If in state 15 then display a green square in this portion of the screen
				IF((HPOS > (H_OFFSET + (3 * H_PIXELS / 4))) AND (HPOS < (H_OFFSET + H_PIXELS))
					AND (VPOS > (V_OFFSET + (3 * V_PIXELS / 4))) AND (VPOS < (V_OFFSET + V_PIXELS))) THEN
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'1'); -- Green = 1
					B<=(OTHERS=>'0'); -- Blue = 0
				ELSE -- If no longer in state 15 then display a black color in this portion of the screen
					R<=(OTHERS=>'0'); -- Red = 0
					G<=(OTHERS=>'0'); -- Green = 0
					B<=(OTHERS=>'0'); -- Blue = 0
				END IF; -- End inner If
			END IF; -- End If 
			IF (HPOS < 1688) THEN -- Increase HPOS if less than 1688
				HPOS <= HPOS +1; -- Add 1 to the sum of the current HPOS value (Each cycle will increase VPOS by 1)
			ELSE -- If HPOS is greater than 1688 
				HPOS <= 0; -- Set HPOS to 0
				IF (VPOS < 1066) THEN  -- Increase VPOS if less than 1066
					VPOS <= VPOS +1; -- Add 1 to the sum of the current VPOS value (Each cycle will increase VPOS by 1)
				ELSE -- If VPOS is greater than 16065
					VPOS <= 0; -- Set VPOS to 0
				END IF; -- End HPOS inner If
			END IF; -- End VPOS If
			-- HPOS and VPOS are two singals that are used to determine the current position on the screen
			IF (HPOS > 48 AND HPOS < 160) THEN -- HSYNC will remain low after the front porch, until it hits the beginning of the back porch
				HSYNC <= '0'; -- Set Horizontal Sync to 0 
			ELSE -- If HPOS is greater than 48 and less than 160
				HSYNC <= '1'; -- Set Horizontal Sync to 1
			END IF; -- END HPOS IF related to front and back porch in which no visuals are displayed on screen
			IF (VPOS > 0 AND VPOS < 4) THEN  -- VSYNC will remain low after the front porch, until it hits the beginning of the back porch
				VSYNC <= '0'; -- Set Vertical Sync to 0 
			ELSE -- If VPOS is greater than 0 and less than 4
				VSYNC <= '1'; -- Set Vertical Sync to 1  
			END IF; -- END VPOS IF related to front and back porch in which no visuals are displayed on screen
			IF ((HPOS > 0 AND HPOS < 408) OR (VPOS > 0 AND VPOS < 42)) THEN -- From the beginning OF BP + pulse SYNC + FP all color channels will be 0
				R <=(OTHERS => '0'); -- Red = 0
				G <=(OTHERS => '0'); -- Green = 0
				B <=(OTHERS => '0'); -- Blue = 0
			END IF; -- End If that setts all color channels to 0 according to VPOS and HPOS position
		END IF; -- End Rising Edge Clock If
	END PROCESS; -- End process
END MAIN; -- End Architecture Main of Sync
