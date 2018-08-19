
# coding: utf-8

# In[1]:

import pandas as pd
import itertools


# In[2]:

visits = pd.read_csv("air_visit_data.csv")
restaurant_info = pd.read_csv("air_store_info.csv")


# In[3]:

print(visits.head())


# In[4]:

print(restaurant_info.head())


# In[5]:

mean_restaurant =  visits.groupby('air_store_id',as_index=False)                         .agg({'visitors':'mean'})                         .rename(columns={'visitors':'mean_v'})


# In[6]:

print(mean_restaurant.head())


# In[7]:

visits = visits.merge(mean_restaurant, on='air_store_id')
restaurant_info = restaurant_info.merge(mean_restaurant, on='air_store_id')


# In[8]:

print(restaurant_info[(restaurant_info['air_area_name']=='Tōkyō-to Shinjuku-ku Kabukichō') &                (restaurant_info['air_genre_name']=='Izakaya')]                .sort_values(['mean_v']))


# I chose these: 
# air_1d1e8860ae04f8e9
# 
# air_2634e41551e9807d 
# 
# air_28064154614b2e6c  #<- Target restaurant (approximately in between the other 4)
# 
# air_2570ccb93badde68
# 
# air_f26f36ec4dc5adb0
# 
# Note: Restaurant air_8f3b563416efc6ad opened later in 2016 so it has much less data than other causing some issues down the road if it was included

# In[9]:

visits = visits[visits['air_store_id'].isin(['air_1d1e8860ae04f8e9','air_2634e41551e9807d',                                             'air_28064154614b2e6c',                                             'air_2570ccb93badde68','air_f26f36ec4dc5adb0'])]


# In[10]:

corrected_visits = pd.DataFrame([x for x in itertools.product(pd.date_range('2016-01-08',visits['visit_date'].max()).astype(str),
                 ['air_1d1e8860ae04f8e9','air_2634e41551e9807d',\
                  'air_28064154614b2e6c',\
                  'air_2570ccb93badde68','air_f26f36ec4dc5adb0'])],columns=['visit_date', 'air_store_id'])


# In[11]:

corrected_visits= corrected_visits.merge(visits,on=['visit_date','air_store_id'],how='left')


# In[12]:

print(corrected_visits.head())


# In[13]:

corrected_visits=corrected_visits.fillna(0)


# In[14]:

corrected_visits.to_csv('E:/Downloads/sde_project_data.csv',quoting=0,index=False)

