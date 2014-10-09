

function [proposal,pi1_pi0] = propose_thetas(Data,kernel,params,schedule)

%%%%%%%%%%
type = 1;%
%%%%%%%%%%

thetai = schedule.paramtoupdate{type};
proposal.params = params;
proposal.type = type;
proposal.subtype = thetai;

if (thetai==1)
  s2loc = params.s2loc;
  for s = 1:Data.nSites
    X = kernel.X{s};
    XC = kernel.XC{s};
    n = Data.nIndiv(s);
    oDinvo = kernel.oDinvoconst(s) ...
           + sum(sum(X.*Data.JtOJ{s}));
    A = sum(sum(X.*Data.JtDJ{s}));
    B = kernel.Bconst(s) ...
      - sum(sum(X.*kernel.cvtJtDJvct{s})) ...
      + sum(sum(XC'*Data.JtDJ{s}*XC));
    trDinvQxD = A - B/oDinvo;
    c = params.s2locShape + (n-1);
    d = params.s2locScale + trDinvQxD;
    s2loc(s) = rinvgam(c/2,d/2);
  end
  proposal.params.s2loc = s2loc;
  % This guarantees that the proposal is always accepted
  % i.e., a Gibbs update
  pi1_pi0 = Inf;
end
