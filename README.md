# Safe shopping during COVID-19 outbreak

The following contents give an brief introduction to the usage of the MAS with Jason. However, for more details about the scenario, please check the [report](./assignment2-section1.pdf). 

## Why am I doing this?

This is the repository related to a coursework assignment of the course *Intelligent Information Systems*[^1].

[^1]: The Department of Engineering Mathematics at the University of Bristol. Course [link](https://www.bris.ac.uk/unit-programme-catalogue/UnitDetails.jsa?ayrCode=19%2F20&unitCode=EMATM0042)

## Variants of base beliefs

**Base beliefs**: All protective measures (Social distancing, timely sanitation and the number of customers at 2) are taken. 

In `customer1.asl`:

```
/* Initial beliefs*/
infected(coronavirus).	
porter(mike).			
thresh_cough(0.5).		
bel_cough(1.0).			
```

In `customer2.asl`:

```
porter(mike).					
thresh_social_distancing(0.5).	
bel_social_distancing(1.0).		
```

In `staff.asl`:

```
limit(2).					
now(1).						
predecessor(john).			
sanitation(tescoExpress).
```

### One customer at a time

**Based on base beliefs**,

- Change the line `limit(2)` in `staff.asl` to `limit(1)`.

Expected result: 

```
[rachel] Shop is clean. Believed not to be infected yet.
```

### No sanitation and one customer at a time

**Based on base beliefs**,

- Change the line `limit(2)` in `staff.asl` to `limit(1)`.
- Comment the line `sanitation(tescoExpress).`.

Expected result: 

```
[rachel] Get infected with the coronavirus
```

### No social distancing

**Based on base beliefs**,

- Change the value `1.0` of the line `bel_social_distancing(1.0).` to a value < 0.5, for example, `0.0`.

Expected result: 

```
[rachel] Not following social distancing from john. Get infected with the coronavirus
```

### No social distancing but no cough

**Based on base beliefs**,

- Change the value `1.0` of the line `bel_social_distancing(1.0).` to a value < 0.5, for example, `0.0`.
- Change the value `1.0` of the line `bel_cough(1.0).` to a value < 0.5, for example, `0.0`.

Expected result: 

```
[rachel] Shop is clean. Believed not to be infected yet.
```

## References

- Hse.gov.uk. 2020. *Social Distancing, Keeping Businesses Open And In-Work Activities During Coronavirus Outbreak - HSE News*. [online] Available at: <https://www.hse.gov.uk/news/social-distancing-coronavirus.htm> [Accessed 27 May 2020].
- Gov.uk. 2020. *Shops And Branches - Working Safely During Coronavirus (COVID-19) - Guidance - GOV.UK*. [online] Available at: <https://www.gov.uk/guidance/working-safely-during-coronavirus-covid-19/shops-and-branches> [Accessed 27 May 2020].
