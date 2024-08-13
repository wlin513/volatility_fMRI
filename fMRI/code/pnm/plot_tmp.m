subplot(3,1,1);plot(acq.data(43500:50000,1));
subplot(3,1,2);plot(acq.data(43500:50000,2));
subplot(3,1,3);plot(acq.data(43500:50000,3));


range=[trigger_index(21711):trigger_index(32594)];
subplot(3,1,1);plot(physio(range,1));
subplot(3,1,2);plot(physio(range,2));
subplot(3,1,3);plot(physio(range,3));