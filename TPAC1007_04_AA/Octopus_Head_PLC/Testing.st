(*[[
]]*)
PROGRAM Testing
#import "Crosstable.gvl"
VAR
	substatus : uint := 0;
	timer : TON;
END_VAR

	case STATUS of
	
	STATUS_IDLE:
		if (PLC_DigIn_1) then (* PLC_PWR_SWITCH *)
			PLC_DigOut_2 := 1;
			PLC_DigOut_3 := 1;
			clearPLC();
			TEST2_COMMAND := TEST_STATUS_REMOTE;
			TEST_STEP := 0;
			RESULT := RESULT_UNKNOWN;
			RESULTS_OK := 0;
			RESULTS_NG := 0;
			STATUS := STATUS_STARTING;
			return;
		end_if;
		
	STATUS_STARTING:
		if (not PLC_DigIn_1) then
			STATUS := STATUS_STOPPING;
			return;
		end_if;
	    if (TEST2_STATUS <> TEST_STATUS_REMOTE) then
	        TEST2_COMMAND := TEST_STATUS_REMOTE;
	    end_if;
	    if (TESTx_STATUS <> TEST_STATUS_REMOTE) then
	        TESTx_COMMAND := TEST_STATUS_REMOTE;
	    end_if;
	    if (TEST2_STATUS = TEST_STATUS_REMOTE and TESTx_STATUS = TEST_STATUS_REMOTE) then
			STATUS := STATUS_READY;
			return;
		end_if;
	
	STATUS_READY:
		(* this state is managed in HMI *)
		substatus := 0;
	
	STATUS_ERROR:
		(* this state is managed in HMI *)
		;
	
	STATUS_TESTING:
		if (not PLC_DigIn_1) then
			STATUS := STATUS_STOPPING;
			return;
		end_if;
		case substatus of
		0: (* clear the OK test variables and write the TST ones *)
			ClearOK();
			substatus := 1;
	    1: (* write the TST test variables *)
			WriteTST();
			substatus := 2;
	    2: (* write the VAL test variables *)
			WriteVAL();
			substatus := 3;
	    3: (* wait for propagation of TST and VAL @ priority 3 : 1000ms *)
			timer(IN := TRUE, PT := T#2000ms);
			if timer.Q then
				timer(IN := FALSE);
				(* write the test starting command *)
		        TEST2_COMMAND := TEST_STATUS_DONE;
		        TESTx_COMMAND := TEST_STATUS_DONE;
				substatus := 4;
			end_if;
	    4: (* wait for propagation of COMMAND @ priority 2 : 500ms and for TPLC005 AnIn *)
			timer(IN := TRUE, PT := T#5000ms); (* TPLC005 AnIn slow *)
			if timer.Q then
				timer(IN := FALSE);
				substatus := 5;
			end_if;
		5: (* waiting for test completion and then read the results *)
		    if (TEST2_STATUS = TEST_STATUS_DONE and TESTx_STATUS = TEST_STATUS_DONE) then
				ReadRES();
				substatus := 6; (* need a step for reading RES %Q *)
				return;
			end_if;
		    if (TEST2_STATUS <> TEST_STATUS_DONE) then
		        TEST2_COMMAND := TEST_STATUS_DONE;
		    end_if;
		    if (TESTx_STATUS <> TEST_STATUS_DONE) then
		        TESTx_COMMAND := TEST_STATUS_DONE;
		    end_if;
		6: (* check RES and VAL *)
			CheckOK();
			substatus := 7;  (* need a step for reading OK %Q *)
		7: (* resume *)
			if AllTestedAreOK() then
				RESULT := RESULT_OK;
				RESULTS_OK := RESULTS_OK + 1;
			else
				RESULT := RESULT_NG;
				RESULTS_NG := RESULTS_NG + 1;
			end_if;
			STATUS := STATUS_DONE;
		else
			;
		end_case;
	
	STATUS_DONE:
		if (not PLC_DigIn_1) then
			STATUS := STATUS_STOPPING;
			return;
		end_if;
		if (AUTOMATIC and RESULT = RESULT_OK) or PLC_DigIn_4 then (* GO *)
			ClearPLC();
			STATUS := STATUS_RESETTING;
			return;
		end_if;
		
	STATUS_RESETTING:
		if (not PLC_DigIn_1) then
			STATUS := STATUS_STOPPING;
			return;
		end_if;
	    if (TEST2_STATUS <> TEST_STATUS_REMOTE) then
	        TEST2_COMMAND := TEST_STATUS_REMOTE;
	    end_if;
	    if (TESTx_STATUS <> TEST_STATUS_REMOTE) then
	        TESTx_COMMAND := TEST_STATUS_REMOTE;
	    end_if;
	    if (TEST2_STATUS = TEST_STATUS_REMOTE and TESTx_STATUS = TEST_STATUS_REMOTE) then
			RESULT := RESULT_UNKNOWN;
			STATUS := STATUS_READY;
			return;
		end_if;
	
	STATUS_STOPPING:
		RESULT := RESULT_UNKNOWN;
	    TEST2_COMMAND := TEST_STATUS_LOCAL;
	    TESTx_COMMAND := TEST_STATUS_LOCAL;
		PLC_DigOut_2 := 0;
		PLC_DigOut_3 := 0;
		STATUS := STATUS_IDLE;
		return;
	
	else
		;
	end_case;
	
END_PROGRAM