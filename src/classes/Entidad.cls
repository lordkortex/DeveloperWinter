public class Entidad{

	private static final String SUFIX_TIME_START = 'StartTime';
	private static final String SUFIX_TIME_END = 'EndTime';
	private static final String WEEK_FORMAT = 'EEEE';

	private static final String STATUS_ENABLED = 'Enabled';
	private static final String STATUS_DISABLED = 'Disabled';


	public Entidad() {
		
	}

	//ffffffffffffff zzz
	public Map<Datetime,String> generateDates(DateTime actualDate){

		Set<Datetime> dateSetReturned = new Set<Datetime>();
		Map<Datetime,String> dateSetReturnedMap = new Map<Datetime,String>();

		Set<Id> userSet = new Set<Id>();
		Set<String> businessHourSet = new Set<String>();
		Map<String,Integer> businessHourUserCounter = new Map<String,Integer>();
					
		// En el metadataType de configuracion tiene que estar : Nombre de PermisionSet,Tiempo de Dias,Tiempo de minutos de llamada
		//String  configurationPermissionSet = '0PS1N000001LuhrWAC';
		String  configurationPermissionSet = 'Agentes_Calendario';
		Integer configurationDays = 7;
		Integer configurationMinutes = 20;


		//Selecciona los usuarios con Permission set especifico.
		//for( PermissionSetAssignment permissionSetAssignmentList  :[ SELECT  AssigneeId FROM PermissionSetAssignment  WHERE PermissionSetId =: configurationPermissionSet]){
		for( PermissionSetAssignment permissionSetAssignmentList  :[ SELECT  AssigneeId FROM PermissionSetAssignment  WHERE PermissionSet.Name =: configurationPermissionSet]){
			userSet.add(permissionSetAssignmentList.AssigneeId);
		}													

		for(User user : [SELECT id,Business_Hour__c FROM User WHERE Id IN: userSet]){
			if(!businessHourSet.contains(user.Business_Hour__c) && !String.isBlank(user.Business_Hour__c)){
				businessHourSet.add(user.Business_Hour__c);

				if(!businessHourUserCounter.containsKey(user.Business_Hour__c)){
					businessHourUserCounter.put(user.Business_Hour__c, 1);
				}else{
					Integer counter = businessHourUserCounter.get(user.Business_Hour__c) + 1;
					businessHourUserCounter.put(user.Business_Hour__c, counter);	
				}
			}
		}

		// Selecciona los distintos Business Hours 
		List<BusinessHours> businessHoursList = getBusinessHours(businessHourSet);

		// Selecciona los distintos Business Hours de esos usuarios			
		if( userSet.isEmpty()){
			System.debug('No existen agentes configurados en los Permission Sets');
			return dateSetReturnedMap; // TODO: Aqui debe lanzar una excepcion.
		}
					
		if( businessHoursList.isEmpty()){
			System.debug('No existen agentes configurados en los Business Hours');
			return dateSetReturnedMap; // TODO: Aqui debe lanzar una excepcion.
		}
					
		//Mapa de Slots generados a partir de Business Hour y candidad de Business Hour por Slot
		Map<Datetime,List<String>> mapSlotBussinesHour  = new Map<Datetime,List<String>>();
		dateSetReturned = buildIntervalSlotsDayWeek(businessHoursList,actualDate,configurationDays,configurationMinutes,mapSlotBussinesHour);

		//Mapa de slot y cantidad de eventos por slot
		//Map<Datetime,Integer> mapEventCounter = getEventGroupedByStartDateMap(userSet,actualDate);											
		//dateSetReturnedMap = buildStatusSlotsMapAvailable(dateSetReturned,mapEventCounter,mapSlotBussinesHour,businessHourUserCounter);
	

		List<Event> eventList = getEventList(userSet,actualDate);											
		dateSetReturnedMap = checkStatusSlotsMapAvailable(dateSetReturned,eventList,mapSlotBussinesHour,businessHourUserCounter);
	
		return dateSetReturnedMap;

	}



	public Map<Datetime,String>  checkStatusSlotsMapAvailable(Set<Datetime> dateSetReturned ,List<Event> eventList,
											Map<Datetime,List<String>> mapSlotBussinesHour,Map<String,Integer> businessHourUserCounter){

		Map<Datetime,String> dateSetReturnedMap = new Map<Datetime,String>();

		for(Datetime slotHour : dateSetReturned){

			List<String> bussinesHourList = mapSlotBussinesHour.get(slotHour);
			//Contara cuantos usuarios existen en un slot especifico los distintos BussinesHour
			Integer userCounterBussinesHour = 0;
			for(String bussinessHourItem : bussinesHourList){
				userCounterBussinesHour += businessHourUserCounter.get(bussinessHourItem);
			}

			Integer counterUserWithEvents = 0;
			for(Event eventItem: eventList){
				if( eventItem.StartDateTime <= slotHour &&  eventItem.EndDateTime > slotHour ){
					counterUserWithEvents +=1;
				}
			}

			Boolean isAvailable = true;
			if(counterUserWithEvents == userCounterBussinesHour){
				isAvailable = false;
			}

			String available = isAvailable ? STATUS_ENABLED : STATUS_DISABLED;
			dateSetReturnedMap.put(slotHour, available);
			System.debug('stringTransformedDateTimeLoop: ' + slotHour + ' Status: ' + available);

			dateSetReturnedMap.put(slotHour, available);

		}

		return dateSetReturnedMap;

	}


	public Map<Datetime,String>  buildStatusSlotsMapAvailable(Set<Datetime> dateSetReturned ,Map<Datetime,Integer> mapEventCounter,
											Map<Datetime,List<String>> mapSlotBussinesHour,Map<String,Integer> businessHourUserCounter){

		Map<Datetime,String> dateSetReturnedMap = new Map<Datetime,String>();

		for(Datetime slotHour : dateSetReturned){
			if(mapEventCounter.containsKey(slotHour)){
				List<String> bussinesHourList = mapSlotBussinesHour.get(slotHour);
				//Contara cuantos usuarios existen en un slot especifico los distintos BussinesHour
				Integer userCounterBussinesHour = 0;
				for(String bussinessHourItem : bussinesHourList){
					userCounterBussinesHour += businessHourUserCounter.get(bussinessHourItem);
				}

				Integer userCounterSlotEvent = mapEventCounter.get(slotHour);

				if(userCounterSlotEvent == userCounterBussinesHour){
					dateSetReturnedMap.put(slotHour, STATUS_DISABLED);
					System.debug('stringTransformedDateTimeLoop: ' + slotHour + ' Status: ' + STATUS_DISABLED);
				}else{
					dateSetReturnedMap.put(slotHour, STATUS_ENABLED);
					System.debug('stringTransformedDateTimeLoop: ' + slotHour + ' Status: ' + STATUS_ENABLED);
				}

			}else{
				dateSetReturnedMap.put(slotHour, STATUS_ENABLED);
				System.debug('stringTransformedDateTimeLoop: ' + slotHour + ' Status: ' + STATUS_ENABLED);
			}

		}

		return dateSetReturnedMap;

	}


	public Map<Datetime,Integer> getEventGroupedByStartDateMap(Set<Id> userSet ,DateTime actualDate){

		Map<Datetime,Integer> eventMap = new Map<Datetime,Integer>();

		List<Event> eventList = [SELECT StartDateTime FROM Event
												WHERE OwnerId IN: userSet  AND  StartDateTime >= :actualDate];
		for(Event event : eventList){
			//String sStartDateTime = String.valueOfGmt(event.startdatetime);
			Datetime  sStartDateTime = event.startdatetime;
			if(!eventMap.containsKey(sStartDateTime)){
				eventMap.put(sStartDateTime, 1);	
			}else{
				Integer counter = eventMap.get(sStartDateTime) + 1;
				eventMap.put(sStartDateTime, counter);	
			}
			
		}												

		return eventMap;

	}


	public List<Event> getEventList(Set<Id> userSet ,DateTime actualDate){

		Map<Datetime,Integer> eventMap = new Map<Datetime,Integer>();

		List<Event> eventList = [SELECT StartDateTime,EndDateTime FROM Event
												WHERE OwnerId IN: userSet  AND  StartDateTime >= :actualDate];
		return eventList;

	}

	
	public List<BusinessHours> getBusinessHours(Set<String> businessHourSet){
	
		List<BusinessHours> businessHoursList = [SELECT Id,Name,FridayEndTime,FridayStartTime,
														MondayEndTime,MondayStartTime,
														SaturdayEndTime,SaturdayStartTime,
														SundayEndTime,SundayStartTime,
														ThursdayEndTime,ThursdayStartTime,
														TuesdayEndTime,TuesdayStartTime,
														WednesdayEndTime,WednesdayStartTime 
												FROM BusinessHours WHERE IsActive = true AND Name IN: businessHourSet ];	

		return businessHoursList;
	}


	public Set<Datetime>  buildIntervalSlotsDayWeek(List<BusinessHours> businessHoursList,DateTime actualDate,Integer configurationDays,Integer configurationMinutes,Map<Datetime,List<String>> mapSlotBussinesHour ){

		Set<Datetime> dateSetReturned = new Set<Datetime>();

		for(BusinessHours businessHoursItem: businessHoursList){
			DateTime incrementedDate = actualDate;
			for(Integer weekDayCounter = 0 ; weekDayCounter <= configurationDays; weekDayCounter++){
				incrementedDate = actualDate.addDays(weekDayCounter);
										
				String weekDay = incrementedDate.format(WEEK_FORMAT);
				String fiedlStarTime = weekDay + SUFIX_TIME_START;
				String fiedlEndTime = weekDay + SUFIX_TIME_END;


				System.debug('fiedlStarTime: ' + businessHoursItem.get(fiedlStarTime));
				System.debug('fiedlEndTime: ' +  businessHoursItem.get(fiedlEndTime));

				Object fiedlStarTimeObject = businessHoursItem.get(fiedlStarTime);
				Object fiedlEndTimeObject = businessHoursItem.get(fiedlEndTime);

				if(fiedlStarTimeObject != null && fiedlEndTimeObject != null){
					Time startTime  = (Time)fiedlStarTimeObject;
					Time endTime    = (Time)fiedlEndTimeObject;
					buildIntervalSlotsTime(startTime,endTime,actualDate,configurationMinutes,incrementedDate,dateSetReturned,businessHoursItem, mapSlotBussinesHour );
				}
			}
		}

		return dateSetReturned;

	}


	public void buildIntervalSlotsTime(Time startTime,Time endTime,DateTime actualDate,
								Integer configurationMinutes ,DateTime incrementedDate,
								Set<Datetime> dateSetReturned,BusinessHours businessHoursItem,Map<Datetime,List<String>> mapSlotBussinesHour  ){
	
		System.debug('startTime: ' + startTime);
		System.debug('endTime: ' +  endTime);


		Datetime startDateTimeLoop = Datetime.newInstanceGMT(incrementedDate.date(), startTime);
		Datetime endDateTimeLoop = Datetime.newInstanceGMT(incrementedDate.date(), endTime);

		System.debug('startDateTimeLoop: ' + startDateTimeLoop);
		System.debug('endDateTimeLoop: ' +  endDateTimeLoop);


		Datetime transformedDateTimeLoop = startDateTimeLoop;
		addDateTimeToSet(transformedDateTimeLoop,actualDate,dateSetReturned,businessHoursItem,mapSlotBussinesHour);

		while (transformedDateTimeLoop < endDateTimeLoop) {
			transformedDateTimeLoop = transformedDateTimeLoop.addMinutes(configurationMinutes);
			addDateTimeToSet(transformedDateTimeLoop,actualDate,dateSetReturned,businessHoursItem,mapSlotBussinesHour);
		}

	}


	public void addDateTimeToSet(final Datetime transformedDateTimeLoop,final DateTime actualDate,
									Set<Datetime> dateSetReturned,BusinessHours businessHoursItem,Map<Datetime,List<String>> mapSlotBussinesHour ){

		if(transformedDateTimeLoop > actualDate ){
			//String stringTransformedDateTimeLoop = String.valueOfGmt(transformedDateTimeLoop);
			//dateSetReturned.add(stringTransformedDateTimeLoop);
			dateSetReturned.add(transformedDateTimeLoop);

			List<String> bussinesHourList = new List<String>();
			if(mapSlotBussinesHour.containsKey(transformedDateTimeLoop)){
				bussinesHourList = mapSlotBussinesHour.get(transformedDateTimeLoop);
			}
			bussinesHourList.add(businessHoursItem.Name);
			mapSlotBussinesHour.put(transformedDateTimeLoop, bussinesHourList);	
		}
	}

}