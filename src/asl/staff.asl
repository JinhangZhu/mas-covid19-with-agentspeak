// Agent staff in project covid19

/* Initial beliefs and rules */
limit(2).					// Max number of customers the shop can contains
now(1).						// current number of customers: 0 initially
predecessor(john).			// John known as the customer who is already in the shop
sanitation(tescoExpress).	// Do sanitation job.

/* Rule */
full(tescoExpress)	:-		// When the current number of customers reaches the limit, 
	limit(M) &				// the shop is believed to be full.
	now(Num) &
	M == Num.

/* Initial goals */
!check_and_clean(tesco).	// Check if someone coughs and do cleaning in shop.

/* Plans */

/* Nothing happens when the shop is alright. */
@cac1
+!check_and_clean(Place)
	:	not aircontaminated(Place, Virus)
		<-	true.

/* When the shop is not clean because of the cough,
 * If sanitation is required, then the staff does the cleaning job.
 */
@cac2
+!check_and_clean(Place)
	:	aircontaminated(Place, Virus) & sanitation(Place)
		<-	.print("Cleaning the interior of ", Place);
			-aircontaminated(Place, Virus);
			.print("The shop is clean now.").

/* When the shop is not clean because of the cough,
 * If sanitation is not required, then the staff does nothing.
 */
@cac3
+!check_and_clean(Place)
	:	aircontaminated(Place, Virus) & not sanitation(Place)
		<-	.print("Nevermind, ", Place, " needs no hygiene according to requirements.").

/* Knowing that the shop is not clean, the staff reminds the customer2 of this 
 * potential threat while letting her in.
 */
@ai1
+!allowin(Customer, Place)
	:	aircontaminated(Place, Virus)
		<-	.print("Letting in ", Place);
			.send(Customer, tell, letin(Place));
			-wantin(Place, Times)[source(Customer)];
			.send(Customer, tell, potential_threat(Place, Virus)).

/* Knowing that the shop is clean, the staff reminds the customer2 that there 
 * is no threat while letting her in.
 */
@ai2		
+!allowin(Customer, Place)
		<-	.print("Letting in ", Place);
			.send(Customer, tell, letin(Place));
			-wantin(Place, Times)[source(Customer)];
			.send(Customer, tell, no_threat(Place)).

/* If the shop is not full, then the staff lets the customer2 in. */
@wi1		
+wantin(Place, Times)[source(Customer)] 
	:	not full(Place)
		<- 	.print("Replied to ", Customer, ". Allowed ", Customer, " to enter in ", Place); 
			!allowin(Customer, Place).
			-wantin(Place, Times)[source(Customer)].

/* If the shop is full and the customer2 just came here, then the staff 
 * needs to have her waiting.
 */
@wi2
+wantin(Place, Times)[source(Customer)] 
	:	full(Place) & Times == 0
		<- 	.print("Apologised to ", Customer, " that the shop is full now so having ", Customer, " waiting for getting in ", Place); 
			.send(Customer, tell, wait(Place)).

/* If the shop is full and the customers2 has requested before, then the staff
 * checks the shop and make the other customer2 notice this.
 */
@wi3
+wantin(Place, Times)[source(Customer)] 
	:	full(Place) &  Times == 1 & predecessor(Pre)
		<- 	.print("Accepted the request from ", Customer, ". Checking ", Place); 
			.send(Pre, tell, another_request(Place, Customer)).

/* Knowing that the customer2 has entered in, the staff increments the current
 * number of customers in the shop.
 */
@e
+entered(Place)[source(Customer)]
	:	predecessor(Pre)
		<-	?now(Num); 
			+now(Num+1);
			.print("There are ", Num+1, " people shopping now.");
			.send(Pre, tell, another(Customer, Place));
			!check_and_clean(Place).

/* Notices that customer2 coughs, believes that the air is contaminated, 
 * and does the cleaning job.
 */
@hc	
+hear_cough(Place, Virus)[source(Customer)]
		<- 	+aircontaminated(Place, Virus);
			.print("OOPS! Realised that ", Customer, " had coughed!");
			!check_and_clean(Place).

/* When knowing that customer1 has left and if there is someone who wants entry, then
 * the staff updates the number of customers in the shop and lets customer2 in.
 */
@fs		
+finish_shopping(Place)[source(Pre)]
	:	wantin(Place, Times)[source(Customer)]
		<-	?now(Num);
			-+now(Num-1);
			-predecessor(Pre);
			.print(Pre, " left. There are ", Num-1, " shopping now.");
			!allowin(Customer, Place).