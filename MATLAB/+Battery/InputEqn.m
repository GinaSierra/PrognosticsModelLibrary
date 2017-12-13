function U = InputEqn(parameters,t,inputParameters)
% InputEqn   Compute model inputs for the given time and input parameters
%
%   U = InputEqn(parameters,t,inputParameters) computes the inputs to the
%   battery model given the parameters structure, the current time, and the
%   set of input parameters. The input parameters are optional - if not
%   provided a default input of 8 Watts is used. If inputParameters is
%   provided, it should be a matrix, numInputParameters x numSamples.

%   For the battery model, the input parameters are a list of numbers
%   specifying a sequence of load segments, with each segment defined by a
%   magnitude and a duration. So, for example, the following input
%   parameters vector:
%      [5 100 2 200 3 300]
%   captures a set of three segments, the first of 5 W lasting 100 seconds,
%   the second 2 W lasting 200 s, the third 3 W lasting 300 s. The initial
%   time is assumed to be 0, so if t is given as 150 s, for example, then
%   the load magnitude will be 2 W (second segment).
%
%   Copyright (c) 2016 United States Government as represented by the
%   Administrator of the National Aeronautics and Space Administration.
%   No copyright is claimed in the United States under Title 17, U.S.
%   Code. All Other Rights Reserved.

function U = InputEqn(parameters,t,inputParameters)

persistent P time loadParameters;
U = [];
if nargin<3
    % If no u specified, assume default load.
    U(1,:) = 8;
else
    if isempty(P) || ~isequal(loadParameters,inputParameters)
        loadParameters=inputParameters;
        loads=loadParameters(1:2:end,:);
        durations=loadParameters(2:2:end,:);
        N=size(loads,2);
        P=zeros(round(max(sum(durations,1))/parameters.sampleTime),N);
        time=0:parameters.sampleTime:size(P,1)*parameters.sampleTime;
        for j=1:N
            temp=[];
            for i=1:size(loads,1)
                temp=[temp; repmat(loads(i,j),round(durations(i,j)/parameters.sampleTime),1) ];
            end
            P(1:length(temp),j)=temp;
            P(length(temp)+1:end,j)=temp(end);
        end
    end

    index = find(t>=time,1,'last');

    if index>size(P,1)
        U(1,:) = P(end,:);
    else
        U(1,:)=P(index,:);
    end
end
