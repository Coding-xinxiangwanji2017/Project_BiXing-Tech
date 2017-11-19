/* UART functions for ATmega32 */


/* Initialize UART */
void USART_Init( unsigned int baudrate )
{
	/* Set the baud rate see datasheet*/
	UBRRH = (unsigned char) (baudrate>>8);                  
	UBRRL = (unsigned char) baudrate;
	
	/* Enable UART receiver and transmitter */
	UCSRB = ( ( 1 << RXEN ) | ( 1 << TXEN ) ); 
	
	/* Set frame format: 8 N 1 */
	UCSRC = (1<<URSEL)|(3<<UCSZ0); 
}


/* Read and write functions */
unsigned char USART_Receive( void )
{
	/* Wait for incomming data */
	while ( !(UCSRA & (1<<RXC)) ) 	
		;			                
	/* Return the data */
	return UDR;
}

void USART_Transmit( unsigned char data )
{
	/* Wait for empty transmit buffer */
	while ( !(UCSRA & (1<<UDRE)) )
		; 			                
	/* Start transmittion */
	UDR = data; 			        
}

unsigned char USART_DataReceived( void )
{
	return (UCSRA & (1<<RXC));	//non 0 if data has been received		
}

void USART_Flush( void )
{
	unsigned char dummy;
	while ( UCSRA & (1<<RXC) ) dummy = UDR;
}
