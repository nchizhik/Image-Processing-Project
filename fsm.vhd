library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fsm is
port 
(		clk			: 	in std_logic;
		rst			: 	in std_logic;
		start		: 	in std_logic;
		
		push		: 	out std_logic;
		done		: 	out std_logic;
		write_en	: 	out std_logic;
		read_address : 	out std_logic_vector (7 downto 0);
		write_address: 	out std_logic_vector (7 downto 0)
);	
end entity fsm;

architecture arc_fsm of fsm is
type stateMachine is (idle, first_line, all_lines, last_line, done_state);
signal current_state: stateMachine;
signal read_address_s, write_address_s: std_logic_vector(7 downto 0):= (others=>'0');
signal push_s, write_en_s, read_en_s, last_line_s, first_line_s: std_logic:='0';

--Signals For Delay The Outputs:
signal write_address_1, write_address_2, write_address_3, write_address_4: std_logic_vector(write_address'HIGH downto 0):= (others=>'0');
signal write_en_1, write_en_2, write_en_3, write_en_4, write_en_5: std_logic:='0';
signal push_1:	std_logic:='0';

begin	
	write_en<=	write_en_4;
	write_address<=	write_address_4;
	read_address<=	read_address_s;
	
	process(clk,rst)
	begin
		if (rst = '1') then 
			read_en_s<=	'0';
			write_en_s<= '0';
			read_address_s<=(others=>'0');
			write_address_s<=(others=>'0');
			push <= '0';
			done <= '0';
			current_state<= idle;
			last_line_s<= '0';
			first_line_s<= '0';
		
		elsif rising_edge(clk) then
		
			-- Delay Signals:
			
			push_1<= push_s;
			push<= push_1;
			
			write_en_1<= write_en_s;
			write_en_2<= write_en_1;
			write_en_3<= write_en_2;
			write_en_4<= write_en_3;
			write_en_5<= write_en_4;
			
			write_address_1<= write_address_s;
			write_address_2<= write_address_1;
			write_address_3<= write_address_2;
			write_address_4<= write_address_3;
			
			--	Counters For ROM:
			if (read_en_s and not(first_line_s) and not(last_line_s))= '1' then
				read_address_s<=	read_address_s+ '1';
			end if;
			
			--	Counter For RAM:
			if (write_en_s and not(first_line_s) and not(last_line_s)) = '1' then
				write_address_s<= write_address_s+ '1';			
			end if;
		
			-- Default Values For Signals:
			current_state<= current_state;
			push_s<= '0';
			read_en_s<= '0';
			write_en_s<= '0';
			first_line_s<= '0';
			last_line_s<= '0';
			
			case current_state is
				when idle=>
					if(start='1') then
						push_s<= '1';
						current_state<=	first_line;
					end if;
				
				when first_line=>
					push_s<= '1';
					read_en_s<=	'1';
					write_en_s<= '1';
					first_line_s<= '1';
					current_state<=	all_lines;
				
				when all_lines=>
					push_s <= '1';
					read_en_s <= '1';
					write_en_s <= '1';
					if (read_address_s= 254) then --Line before the last
						last_line_s	<= '1';
						current_state<=	last_line;
					end if;
				when last_line=>
					push_s <= '1';
					read_en_s <= '1';
					write_en_s <= '1';
					current_state<=	done_state;
				
				when done_state=>
					if (write_address_4 = 255) then
						done<= '1';
					end if;	
				
				when others=>
					current_state<=	idle;
				end case;
		end if;
	end process;
end architecture arc_fsm;
