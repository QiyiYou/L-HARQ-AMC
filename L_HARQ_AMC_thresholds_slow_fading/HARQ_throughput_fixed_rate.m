clear;
clc;

% maximum number of transmissions
K=2;
% rate set
pas=0.75
R_set=[pas:pas:3.75];
L=length(R_set);
% decay value, used in PER exoression
a=0.5;
% decoding threshold, used in PER expression 
snrth=@(R) 2.^R-1;
snrth_set=snrth(R_set)
% optimal threshold, 
gamma=@(l) snrth(R_set(l)).*(1+log(R_set(l)./(R_set(l)-R_set(l-1)))./a);
% SNR in dB
SNRdB=[-5:30];
% SNR pdf, av_snr=channel average SNR
pdf_snr=@(x,av_snr) exp(-x./av_snr)./av_snr;
% SNR cdf
cdf_snr=@(x,av_snr) 1-exp(-x./av_snr);
% PER average
PER=@(l,x,av_snr) pdf_snr(x,av_snr).*WEP(x,snrth_set(l),a);
% Legend integral 
lint = 500;
[x0, w] = GaussLegendre(lint);


%% Computation of optimal thresholds, R_l \in[gamma(l),gamma(l+1)[
gamma_op(1)=0;
for l=2:L
    gamma_op(l)=gamma(l);
end

%% Computation of throughput
for ind_snr=1:length(SNRdB)
    snr=10.^(SNRdB(ind_snr)./10);
    gamma_op(L+1)=snr*30;
    [Throughput,Parity_Rate_set,snr_space(ind_snr,:)]=DP_algorithme_fixed_rate(R_set,snrth_set,gamma_op,snr,a,K,L);
    [val,I]=max(Throughput);
    Dx=gamma_op(L+1);
    x=(x0+1)*Dx/2;
    xtemp0=interp1(snr_space(ind_snr,:),val,x);
    % throughput.
    xtemp=xtemp0.*pdf_snr(x,snr);
    T_corre(ind_snr)=sum(xtemp.*w)*Dx/2;
    Rate_corre(ind_snr,:)=R_set(I);
    % outage
   % parity{ind_snr}=Parity_Rate(I,;
    
end

save(['exact_slow_fading_LHARQ_R_', num2str(L),'_a_',num2str(a),'_K_',num2str(K),'.mat'])



% semilogx(snr_space,T_corre{ind_snr}(1,:),'r')
% 
% hold on
% 
% semilogx(snr_space,T_corre{ind_snr}(2,:),'b')
% 
% semilogx(snr_space,T_corre{ind_snr}(3,:),'g')
% 
% semilogx(snr_space,T_corre{ind_snr}(4,:),'c')
% 
% semilogx(snr_space,T_corre{ind_snr}(5,:),'k')
% 
% legend('l=1','l=2','l=3','l=4','l=5')



%save(['slow_fading_LHARQ_R_', num2str(L),'_a_',num2str(a),'_K_',num2str(K),'.mat'])

% figure(3)
% plot(SNRdB,T_corre,'b')
% grid

% figure(2)
% semilogy(SNRdB, outage(:,1),SNRdB, outage(:,2),SNRdB, outage(:,3),SNRdB, outage(:,4),SNRdB, outage(:,5))
% legend('l=1','l=2','l=3','l=4','l=5')







