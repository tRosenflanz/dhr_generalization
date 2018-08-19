%Reading Data, standardizing it to the mean and constructing
%training/forecasting data

visits = readtable('sde_project_data.csv')
rest_1 = visits(string(visits.air_store_id)=='air_1d1e8860ae04f8e9',:)
rest_2 = visits(string(visits.air_store_id)=='air_2570ccb93badde68',:)
rest_3 = visits(string(visits.air_store_id)=='air_2634e41551e9807d',:)
rest_4 = visits(string(visits.air_store_id)=='air_f26f36ec4dc5adb0',:)
rest_Test = visits(string(visits.air_store_id)=='air_28064154614b2e6c',:)
dates = rest_1.visit_date
means= [max(rest_1.mean_v) max(rest_2.mean_v) max(rest_3.mean_v)...
        max(rest_4.mean_v) max(rest_Test.mean_v)]
rests_full = [rest_1.visitors rest_2.visitors rest_3.visitors...
         rest_4.visitors rest_Test.visitors]
for i=1:5
    rests_full(:,i)=rests_full(:,i)/means(i)
end
rests_train = []
for i=1:4
    rests_train(:,i)=fcast(rests_full(1:end-100,i),100)
end

plot(dates,[rests_full(:,1) rests_full(:,4)])
legend('Restaurant 1', 'Restaurant 4')

%Extracting AR SPECTRUM
nvrs = []
P = [0 180 21 7 3.5]
for i = 1:4
    nvrs= [nvrs dhropt(rests_train(:,i), P ,1)]
    hold on 
end    
hold off

%Fitting the models to Training dataset
fits=[]
residuals=[]
naive_residuals=[]
for i = 1:4
    fit = dhr(rests_train(:,i), P ,[],nvrs(:,i))
    fit(rests_full(:,i)==0)=0
    residuals(:,i)=rests_full(:,i)-fit
    naive_residuals(:,i)=rests_full(:,i)-(rests_full(:,i)>0)
    fits(:,i)= fit
end

%Construct graphs for a specific restaurant i
i=4
plot(dates,[fits(:,i) rests_full(:,i)])
line([dates(end-99) dates(end-99)], [0 max(rests_full(:,i))+.5],...
     'Color','black','LineStyle','--')
legend('fit','actual', 'prediction threshold')

%residuals vs predicting average
plot(dates,[residuals(:,i) naive_residuals(:,i)])
line([dates(end-99) dates(end-99)], [-5 5],...
     'Color','black','LineStyle','--')
legend('residual','no fit residual', 'prediction threshold')


%residual fit
mean(abs(residuals(1:end-100,:)),1)
%residual predict
mean(abs(residuals(end-99:end,:)),1)
%residuals naive
mean(abs(naive_residuals),1)

%Section 5. Holdout restaurant exploration


n=30
rests_train(:,5)=fcast(rests_full(176:176+n-1,5),[0 296-n;175 0])
P = [0 21 7 3.5]
%Constructing different NVRs
nvr_fit = dhropt(rests_train(176:end,5), P ,1)
nvr_al_mean=mean(nvrs(1:end~=2,:),2)
nvr_geom_mean=geomean(nvrs(1:end~=2,:),2)
%Fitting Models
fit = dhr(rests_train(:,5), P ,[],nvr_fit)
fit_al=dhr(rests_train(:,5), P ,[],nvr_al_mean)
fit_geom=dhr(rests_train(:,5), P ,[],nvr_geom_mean)
fits=[fit fit_al fit_geom]
fits(rests_full(:,5)==0,:)=0

%Plotting for model i
plot(dates,[fits(:,i) rests_full(:,5)])
line([dates(176) dates(176)], [0 max(rests_full(:,5))+.5],...
     'Color','black','LineStyle','--')
line([dates(176+n-1) dates(176+n-1)], [0 max(rests_full(:,5))+.5],...
     'Color','black','LineStyle','--') 
legend('geometric mean nvrs','actual')

%Plotting residuals
residuals= rests_full(:,5)-fits
naive_residual = rests_full(:,5)-(rests_full(:,5)>0)
naive_average_resid = rests_full(:,5)-mean(rests_full(:,1:4),2)
naive_average_resid((rests_full(:,5)==0))=0

%residual fit
mean(abs(residuals(176:176+n-1,:)),1)
%residual predict
mean(abs(residuals(176+n:end,:)),1)
%residuals naive
mean(abs(naive_residual))
%residuals naive average of other
mean(abs(naive_average_resid))
plot(dates,residuals)
line([dates(176) dates(176)], [-3 3],...
     'Color','black','LineStyle','--')
line([dates(176+n-1) dates(176+n-1)], [-3 3],...
     'Color','black','LineStyle','--') 
legend('fit nvr residuals','mean nvrs residuals')

%Exploring training NVRs as the regularizer to holdout NVR
fits=dhr(rests_train(:,5), P ,[],mean([nvr_fit nvrs(1:end~=2,:)],2))
fits(rests_full(:,5)==0,:)=0

plot(dates,[fits(:,1) rests_full(:,5)])
line([dates(176) dates(176)], [0 max(rests_full(:,5))+.5],...
     'Color','black','LineStyle','--')
line([dates(176+n-1) dates(176+n-1)], [0 max(rests_full(:,5))+.5],...
     'Color','black','LineStyle','--') 
legend('geometric mean nvrs','actual')

residuals= rests_full(:,5)-fits
naive_residual = rests_full(:,5)-(rests_full(:,5)>0)
naive_average_resid = rests_full(:,5)-mean(rests_full(:,1:4),2)
naive_average_resid((rests_full(:,5)==0))=0
%residual fit
mean(abs(residuals(176:176+n-1,:)),1)
%residual predict
mean(abs(residuals(176+n:end,:)),1)
%residuals naive
mean(abs(naive_residual))
%residuals naive average of other
mean(abs(naive_average_resid))

