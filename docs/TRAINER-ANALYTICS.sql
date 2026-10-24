-- Тренажёры: кто и чем пользуется. ТОЛЬКО ЧТЕНИЕ (select), без имён учеников.
-- Выполнять по одному запросу в Supabase → SQL Editor проекта ai-ijodkor-platform.
-- Важно: trainer_sessions пишется только при ЗАВЕРШЕНИИ прохождения уровня/режима,
-- поэтому «открыл и бросил» в данных не видно — это видно по разрыву между «открывали» (нет) и «завершили».

-- 0. Сколько активных учеников (знаменатель для всех процентов)
select count(*) as active_students from profiles where role = 'student' and archived_at is null;

-- 1. Воронка по тренажёрам: сколько учеников завершало, как часто, свежесть
select trainer_key,
       count(distinct student_id)                                             as students,
       count(*)                                                               as sessions,
       round(count(*)::numeric / count(distinct student_id), 1)               as sessions_per_student,
       count(distinct student_id) filter (where played_at > now() - interval '30 days') as students_30d,
       count(*) filter (where played_at > now() - interval '30 days')         as sessions_30d,
       round(avg(score))                                                      as avg_score,
       max(played_at)::date                                                   as last_played
from trainer_sessions
group by trainer_key
order by students desc;

-- 2. Тренажёры, которые вообще никто не завершал (нет строк в запросе 1)
select k as trainer_key
from unnest(array['typing','mouse','shortcuts','files-folders','internet-safety','godot','word','excel','excel-pro',
                  'python','blocks','code-output','debug','python-brain','logic','critical-thinking','prompting',
                  'prompt-checklist','experiment-lab','teacher-simulator']) as k
where k not in (select distinct trainer_key from trainer_sessions);

-- 3. «Одноразовые»: доля учеников, которые сыграли ровно один раз и не вернулись
select trainer_key,
       count(*) filter (where n = 1)                                  as one_and_done,
       count(*)                                                       as players,
       round(100.0 * count(*) filter (where n = 1) / count(*))        as one_and_done_pct
from (select trainer_key, student_id, count(*) n from trainer_sessions group by 1, 2) t
group by trainer_key
order by one_and_done_pct desc;

-- 4. Непонимание: точность на уровне 1 (низкая точность и 0–1 звезда = дети не понимают механику)
select trainer_key,
       count(*)                                                  as level1_runs,
       round(avg((metrics->>'accuracy')::int))                   as avg_accuracy,
       round(avg((metrics->>'stars')::int), 1)                   as avg_stars,
       round(100.0 * count(*) filter (where (metrics->>'accuracy')::int < 50) / count(*)) as pct_accuracy_below_50
from trainer_sessions
where metrics->>'mode' = 'level' and metrics->>'level' in ('1','easy','l1')
group by trainer_key
order by avg_accuracy;

-- 4b. Если уровни называются иначе, посмотрите значения:
select metrics->>'level' as level, count(*) from trainer_sessions where metrics->>'mode' = 'level' group by 1 order by 2 desc;

-- 5. Доходят ли до следующих уровней (сколько учеников на каждом уровне)
select trainer_key, metrics->>'level' as level, count(distinct student_id) as students, round(avg((metrics->>'stars')::int), 1) as avg_stars
from trainer_sessions
where metrics->>'mode' = 'level'
group by 1, 2
order by 1, 2;

-- 6. Ученики, которые не завершили НИ ОДНОГО тренажёра (охват)
select count(*) as never_played
from profiles p
where p.role = 'student' and p.archived_at is null
  and not exists (select 1 from trainer_sessions s where s.student_id = p.id);

-- 7. Динамика по неделям (растёт ли интерес)
select date_trunc('week', played_at)::date as week, count(*) as sessions, count(distinct student_id) as students
from trainer_sessions
group by 1 order by 1 desc limit 12;
