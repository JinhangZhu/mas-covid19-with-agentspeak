// Agent customer1 in project covid19

/* Initial beliefs*/
infected(coronavirus).	// Believed to be infected with coronavirus
porter(mike).			// Believe that Mike is the porter
thresh_cough(0.5).		// The threshold that agent is believed to cough or sneeze
bel_cough(1.0).			// The belief of cough

/* Rules */
do_cough(Bel) :-		// Whether the customer coughs 
	bel_cough(Bel) &	// Bel > 0.5, coughing happens
	thresh_cough(Thresh) &
	Bel > Thresh.
	
/* Initial goals */
!shop(tescoExpress).	// To shop in tescoExpress

/* Plans */

/* If there is no new customer who enter in or there is no new request to enter in, 
then the agent customer1 keeps shopping.*/
@s11
+!shop(Place) 
	:	not new_customer(Customer) & not new_coming(Customer)
		<- 	?infected(Virus);
			.print("Infected with ", Virus, ". Shopping in ", Place).

/* If the belief of cough is greater than the threshold, the agent customer1 coughs 
 * and leaves. */
@s12
+!shop(Place)
	:	do_cough(Bel) & (new_customer(Customer) | new_coming(Customer))
		<- 	?thresh_cough(Thresh);
			.print("The belief of cough is ", Bel, " > ", Thresh);
			!cough(Place);
			!leave(Place).

/* If the belief of cough is not greater than the threshold, the agent customer1
 * just leaves. */			
@s13
+!shop(Place)
	:	not do_cough(Bel)  & (new_customer(Customer) | new_coming(Customer))
		<- 	?thresh_cough(Thresh);
			?bel_cough(Bel);
			.print("The belief of cough is ", Bel, " <= ", Thresh);
			!leave(Place).

/* Leave the shop and let the staff/porter notice his departure. */
@l	
+!leave(Place)
	:	porter(Staff)
		<-	-+new_customer(Customer);
			-+new_coming(Customer);
			.print("Finished shopping and left ", Place);
			.send(Staff, tell, finish_shopping(Place)).

/* Cough and sneeze while spreading the virus.
 * Make new customer: agent customer2 skeptical whether she get infected. 
 * Make the staff/porter notice his cough. */
@c1		
+!cough(Place)
	:	 new_customer(Customer)
		<-	.print("'Ah-choo!' Coughed and sneezed!");
			?infected(Virus);
			.send(Customer, tell, infect(Place, Virus));
			?porter(Staff);
			.send(Staff, tell, hear_cough(Place, Virus)).

/* When there is no new customer: agent customer2, the agent customer1
 * just make the staff/porter notice the situation. */
@c2	
+!cough(Place)
	:	not new_customer(Customer)
		<-	.print("Ah-choo!");	
			?infected(Virus);
			?porter(Staff);
			.send(Staff, tell, hear_cough(Place, Virus)).

/* Receive the tell message that there is another customer: agent customer2
 * entering into the shop. The agent customer1 keeps shopping. */
@a
+another(Customer, Place)[source(Staff)]
		<-	+new_customer(Customer);
			!shop(Place).

/* Receive the tell message that there is another customer: agent customer2
 * coming to enter in. The agent customer1 keeps shopping. */
@ar		
+another_request(Place, Customer)[source(Staff)]
		<-	+new_coming(Customer);
			!shop(Place).