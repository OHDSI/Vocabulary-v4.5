create or replace package pkg_concept_ancestor is
  -- Created : 21.09.2014 17:17:32
  -- Purpose : Script to create hieararchy tree 
  
  -- Public type declarations
  --type <TypeName> is <Datatype>;
  
  -- Public constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
  --<VariableName> <Datatype>;

  -- Public function and procedure declarations
  --function <FunctionName>(<Parameter> <Datatype>) return <Datatype>;
  function IsSameTableData (pTable1 in varchar2, pTable2 in varchar2 ) return boolean;

  procedure calc;
  


end pkg_concept_ancestor;
/
create or replace package body pkg_concept_ancestor is

  -- Private type declarations
  --type <TypeName> is <Datatype>;
  
  -- Private constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  --<VariableName> <Datatype>;

  -- Function and procedure implementations
  ------------------------------------------------------------------------
  function IsSameTableData (pTable1 in varchar2, pTable2 in varchar2 ) return boolean
  is
    vRefCursor sys_refcursor;
    vDummy char(1);
    
    res boolean;
  begin
    open vRefCursor for 'select null as col1 from ( select * from ' || pTable1 ||' minus select * from ' || pTable2 || ' )';
      fetch vRefCursor into vDummy;
      res := vRefCursor%NOTFOUND;
    close vRefCursor;
    
    return res;
  end IsSameTableData;
  ------------------------------------------------------------------------
  procedure calc
  is
    vApplication_name constant varchar2(20) := 'CONCEPT_ANSESTOR';
    vProcedure_name constant varchar2(50) := 'CALC';
    
    vCnt integer;
    vCnt_old integer;
    vSumMax integer;
    vSumMax_old integer;
    vSumMin integer;
    vIsOverLoop boolean;
  begin
    add_application_log ( pApplication_name => vApplication_name, pProcedure_name => vProcedure_name, pDetail => 'Start' );

    -- Clean up before
    begin execute immediate 'drop table concept_ancestor_calc purge'; exception when others then null; end;
    begin execute immediate 'drop table concept_ancestor_calc_bkp purge'; exception when others then null; end;
    begin execute immediate 'drop table new_concept_ancestor_calc purge'; exception when others then null; end;

    -- Seed the table by loading all first-level (parent-child) relationships
    execute immediate 'create table concept_ancestor_calc as
select 
  r.concept_id_1 as ancestor_concept_id,
  r.concept_id_2 as descendant_concept_id,
  case when s.is_hierarchical=1 and c1.concept_level>=1 then 1 else 0 end as min_levels_of_separation,
	case when s.is_hierarchical=1 and c1.concept_level>=1 then 1 else 0 end as max_levels_of_separation
from concept_relationship r 
join relationship s on s.relationship_id=r.relationship_id and s.defines_ancestry=1
join concept c1 on c1.concept_id=r.concept_id_1 and c1.invalid_reason is null
join concept c2 on c2.concept_id=r.concept_id_2 and c1.invalid_reason is null
where r.invalid_reason is null ';
   
    /********** Repeat till no new records are written *********/
    for i in 1 .. 100
    loop
      -- create all new combinations
      add_application_log ( pApplication_name => vApplication_name
                           ,pProcedure_name => vProcedure_name
                           ,pDetail => 'Begin new_concept_ancestor_calc i=' || i );
                           
      execute immediate ' create table new_concept_ancestor_calc as
select 
	uppr.ancestor_concept_id,
	lowr.descendant_concept_id,
	uppr.min_levels_of_separation+lowr.min_levels_of_separation as min_levels_of_separation,
	uppr.min_levels_of_separation+lowr.min_levels_of_separation as max_levels_of_separation	
from concept_ancestor_calc uppr 
join concept_ancestor_calc lowr on uppr.descendant_concept_id=lowr.ancestor_concept_id
union all select * from concept_ancestor_calc ';
      
      execute immediate 'select count(*) as cnt from new_concept_ancestor_calc' into vCnt;

      add_application_log ( pApplication_name => vApplication_name
                           ,pProcedure_name => vProcedure_name
                           ,pDetail => 'End new_concept_ancestor_calc i=' || i || ' cnt=' || vCnt );

      execute immediate 'drop table concept_ancestor_calc purge';
      
      -- Shrink and pick the shortest path for min_levels_of_separation, and the longest for max     
      add_application_log ( pApplication_name => vApplication_name
                     ,pProcedure_name => vProcedure_name
                     ,pDetail => 'Begin concept_ancestor_calc i=' || i );
                     
      execute immediate 'create table concept_ancestor_calc as
select 
	ancestor_concept_id,
	descendant_concept_id,
	min(min_levels_of_separation) as min_levels_of_separation,
	max(max_levels_of_separation) as max_levels_of_separation
from new_concept_ancestor_calc
group by ancestor_concept_id, descendant_concept_id ';

      execute immediate 'select count(*), sum(max_levels_of_separation), sum(min_levels_of_separation) from concept_ancestor_calc' into vCnt, vSumMax, vSumMin;
      
      add_application_log ( pApplication_name => vApplication_name
       ,pProcedure_name => vProcedure_name
       ,pDetail => 'End concept_ancestor_calc i=' || i  || ' cnt=' || vCnt || ' SumMax=' || vSumMax || ' SumMin=' || vSumMin );

      execute immediate 'drop table new_concept_ancestor_calc purge';
      
      if vIsOverLoop then
          add_application_log ( pApplication_name => vApplication_name, pProcedure_name => vProcedure_name, pDetail => 'loop exit i=' || i );
          
          if vCnt = vCnt_old and vSumMax = vSumMax_old
            then
              if IsSameTableData ( pTable1 => 'concept_ancestor_calc',pTable2 => 'concept_ancestor_calc_bkp' )
                then
                  add_application_log ( pApplication_name => vApplication_name, pProcedure_name => vProcedure_name
                          ,pDetail => 'Table same. loop exit i=' || i );
                  exit;
                else
                  add_application_log ( pApplication_name => vApplication_name, pProcedure_name => vProcedure_name
                          ,pDetail => 'Table different. loop return i=' || i );
                  return;
              end if;
            else
              add_application_log ( pApplication_name => vApplication_name, pProcedure_name => vProcedure_name
                , pDetail => 'Table count different. loop return i=' || i );
              return;
          end if;
      elsif vCnt = vCnt_old then
        add_application_log ( pApplication_name => vApplication_name, pProcedure_name => vProcedure_name, pDetail => 'count same. loop i=' || i );
        execute immediate 'create table concept_ancestor_calc_bkp as select * from concept_ancestor_calc ';
        vIsOverLoop := true;
      end if;               
      
      vCnt_old := vCnt;
      vSumMax_old := vSumMax;
    end loop; /********** Repeat till no new records are written *********/
    
    add_application_log ( pApplication_name => vApplication_name
                     ,pProcedure_name => vProcedure_name
                     ,pDetail => 'Remove all non-Standard concepts (concept_level=0)' );

    execute immediate 'truncate table concept_ancestor';
    
    -- drop concept_ancestor indexes before mass insert.
    execute immediate 'alter table concept_ancestor disable constraint XPKCONCEPT_ANCESTOR';

    execute immediate 'insert into concept_ancestor
  select a.* from concept_ancestor_calc a
    join concept_stage c1 on a.ancestor_concept_id=c1.concept_id
    join concept_stage c2 on a.descendant_concept_id=c2.concept_id
       where c1.concept_level>0 and c2.concept_level>0
';
    commit;
    
    -- Create concept_ancestor indexes after mass insert.
    add_application_log ( pApplication_name => vApplication_name, pProcedure_name => vProcedure_name, pDetail => 'Enable CONCEPT_ANCESTOR PK' );
    execute immediate 'alter table concept_ancestor enable constraint XPKCONCEPT_ANCESTOR';

    add_application_log ( pApplication_name => vApplication_name, pProcedure_name => vProcedure_name
      ,pDetail => 'Add connections to self for those vocabs having at least one concept.' );

    -- Add connections to self for those vocabs having at least one concept in the concept_relationship table
    insert into concept_ancestor
    select 
      concept_id as ancestor_concept_id,
      concept_id as descendant_concept_id,
      0 as min_levels_of_separation,
      0 as max_levels_of_separation
    from concept_stage 
    where vocabulary_id in (
      select c.vocabulary_id from concept_relationship_stage r, concept_stage c where c.concept_id=r.concept_id_1
      union
      select c.vocabulary_id from concept_relationship_stage r, concept_stage c where c.concept_id=r.concept_id_2
    )
    and invalid_reason is null and concept_level!=0
    ;
    commit;
    -- Clean up       
    add_application_log ( pApplication_name => vApplication_name, pProcedure_name => vProcedure_name, pDetail => 'Clean up' );
   -- execute immediate 'drop table new_concept_ancestor_calc purge';    
    execute immediate 'drop table concept_ancestor_calc purge';
    execute immediate 'drop table concept_ancestor_calc_bkp purge';

    add_application_log ( pApplication_name => vApplication_name, pProcedure_name => vProcedure_name, pDetail => 'End' );
  exception when others then
    add_application_log ( pApplication_name => 'CONCEPT_ANSESTOR'
                         ,pProcedure_name => 'CALC SqlCode=' || sqlcode
                         ,pDetail => dbms_utility.format_error_stack || dbms_utility.format_error_backtrace );
    raise;
  end calc;
  ------------------------------------------------------
  

end pkg_concept_ancestor;
/
