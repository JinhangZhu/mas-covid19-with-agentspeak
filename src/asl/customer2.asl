// Agent customer2 in project covid19

/* Initial beliefs*/
porter(mike).					// Mike is the porter
thresh_social_distancing(0.5).	// The threshold of belief that the agent follows the social distancing rule from customer1.
bel_social_distancing(1.0).		// The belief that the agent follows the social distancing rule from customer1.

/* Rules */
social_distancing(john, Bel) :-		// Whether the customers do social distancing 
	bel_social_distancing(Bel)	&	// Bel > 0.5, do social distancing 									
	thresh_social_distancing(Thresh) &
	Bel > Thresh.
	
/* Initial goals */
!shop(tescoExpress).		// To shop in tescoExpress

/* Plans */

/* If there is a porter and the agent customer2 has not been told to wait,
 * then agent customer2 tells the porter that she wants entry.
 */
@s21
+!shop(Place) 
	:	porter(Staff) & not wait(Place)[source(Staff)]
		<- 	.print("Talked to ", Staff, ": Would like to shop in ", Place); 
			.send(Staff, tell, wantin(Place, 0)).

/* If the agent customer2 is still waiting, she will try to ask if she can enter in. */
@s22
+!shop(Place) 
	:	wait(Place)[source(Staff)]
		<- 	.print("Sending a new request to ", Staff, " for the entry into ", Place);
			.send(Staff, tell, wantin(Place, 1)).

/* If she is allowed, then she enters in. */		
@li		
+letin(Place)[source(Staff)] 
		<- 	.print("Thanked ", Staff, ". Shopping in ", Place);
			.send(Staff, tell, entered(Place)).

/* When told to wait, then wait. But with the goal to shop. */
@w
+wait(Place)[source(Staff)]
		<-	.print("Thanked ", Staff, ". Waiting outside ", Place);
			!shop(Place).

/* Realised that the other customer1 coughed. If they are not doing social
 * distancing, then customer2 is believed to be infected.
 */
@i1		
+infect(Place, Virus)[source(Customer)]
	:	not social_distancing(Customer, Bel)
		<-	+infected(Virus);
			?thresh_social_distancing(Thresh);
			?bel_social_distancing(Bel);
			.print("The belief of social distancing is ", Bel, " <= ", Thresh);
			.print("Not following social distancing from ", Customer, ". Get infected with the ", Virus).

/* Realised that the other customer1 coughed. If they are doing social
 * distancing, then customer2 is not believed to be infected.
 */
@i2
+infect(Place, Virus)[source(Customer)]
	:	social_distancing(Customer, Bel)
		<-	-+infected(Virus);
			?thresh_social_distancing(Thresh);
			.print("The belief of social distancing is ", Bel, " > ", Thresh);
			.print("Following social distancing from ", Customer, ". Feeling weird but not infected with the ", Virus).

/* With the idea that there is potential threat of getting infected but still enters in, 
 * the customer2 is believed to be infected.
 */			
@pt		
+potential_threat(Place, Virus)[source(Staff)]
		<-	+infected(Virus);
			.print("Get infected with the ", Virus).

/* With the idea that there is no threat of getting infected and enters in, 
 * the customer2 is not believed to be infected.
 */
@nt
+no_threat(Place)[source(Staff)]
		<-	.print("Shop is clean. Believed not to be infected yet.").