%%% Author: Temmie %%%
%%% Time: 7/6/2024 %%%

% 创建webcam对象
cam = webcam();

% 打开图形窗口
hFig = figure;
set(hFig, 'Name', 'Demo · 手势鼠标', 'NumberTitle', 'off');

% 创建四个子图位置
hAx1 = subplot(2, 2, 1, 'Parent', hFig); % 原视频
hAx2 = subplot(2, 2, 2, 'Parent', hFig); % 处理中画面
hAx3 = subplot(2, 2, 3, 'Parent', hFig); % 处理后标号
hAx4 = subplot(2, 2, 4, 'Parent', hFig); % 当前状态文本

redThresh = [0.95, 0.05]; % 定义HSV空间中红色的范围
satThresh = [0.6, 1]; % 饱和度阈值
valThresh = [0.4, 1]; % 亮度值阈值

% 定义手指保留检测最大移动距离
fingerDisplacementThreshold = 100;

% 初始化上一帧手指的位置为空
lastPositions = containers.Map({'1', '2'}, {[], []});

% 初始化上一帧手指的活跃状态
fingerActiveStatesactivate = containers.Map({'1', '2'}, {false, false});

% 全局手指标签列表
allFingerLabels = {'1', '2'};

% 初始化2号手指的上一个位置，2号手指是定位手指
lastPosition2 = [];

% 设置鼠标移动的灵敏度调节值
scaleFactor = 2.0; 

% 按键判断值
isLeftPressed = false;
isRightPressed = false;

% 阈值
moveThreshold = 5;

% 持续捕获图像直到图形窗口关闭
while ishandle(hFig)
    % 重置手指的活跃状态，避免滞留
    for label = allFingerLabels
        fingerActiveStates(label{1}) = false;
    end

    % 捕获一帧图像并镜像
    frame = flip(snapshot(cam), 2);
    
    % 将图像从RGB转换为HSV色彩空间
    hsvImage = rgb2hsv(frame);
    
    % 创建红色掩膜
    redMask = (hsvImage(:,:,1) >= redThresh(1) | hsvImage(:,:,1) <= redThresh(2)) & ...
              (hsvImage(:,:,2) >= satThresh(1) & hsvImage(:,:,2) <= satThresh(2)) & ...
              (hsvImage(:,:,3) >= valThresh(1) & hsvImage(:,:,3) <= valThresh(2));
    
    % 对掩膜进行形态学处理以减少噪声
    redMask = imopen(redMask, strel('disk', 5));
    redMask = imclose(redMask, strel('disk', 5));
    
    % 找到红色区域的质心和面积
    props = regionprops(redMask, 'Centroid', 'Area');
    
    % 仅保留符合面积要求的对象
    minArea = 1000; % 最小的手指面积（红色区域面积）
    props = props(arrayfun(@(x) x.Area >= minArea, props));
    
    % 标签帧
    labeledFrame = frame;

    % 处理帧
    filteredFrame = frame;
    filteredFrame(repmat(~redMask, [1, 1, 3])) = 0; % 设置非红色区域为黑色
    
    if ~isempty(props)
        % 对质心按X坐标排序
        centroids = cat(1, props.Centroid);
        [~, sortIdx] = sort(centroids(:,1));
        propsSorted = props(sortIdx);
        
        for idx = 1:min(2, length(propsSorted))
            centroid = propsSorted(idx).Centroid;
            found = false;
            
            % 尝试匹配先前的手指，实现手指标号定位
            for fingerId = {'1', '2'}
                lastPosition = lastPositions(fingerId{1});
                if ~isempty(lastPosition) && norm(centroid - lastPosition) < fingerDisplacementThreshold
                    % 更新位置
                    lastPositions(fingerId{1}) = centroid;
                    fingerActiveStates(fingerId{1}) = true;
                    found = true;
                    label = fingerId{1};
                    break;
                end
            end
            
            % 如果未匹配现有手指，则分配一个新的手指ID
            if ~found
                for key = keys(lastPositions)
                    % 确保该手指标签当时不活跃
                    if ~fingerActiveStates(key{1}) % && isempty(lastPositions(key{1}))
                        lastPositions(key{1}) = centroid;
                        fingerActiveStates(key{1}) = true; % 将手指标签设为活跃
                        label = key{1};
                        found = true; 
                        break;
                    end
                end
            end

            % 在图像上标记手指
            if found
                labeledFrame = insertText(labeledFrame, centroid, label, 'FontSize', 18, 'BoxColor', 'yellow', 'TextColor', 'black');
            end
        end
    end

    import java.awt.Robot;
    import java.awt.event.*;

    mouse = Robot;
    
    % 当前手势状态逻辑
    currentGesture = '未检测到手势'; % 默认手势状态
    finger1Detected = fingerActiveStates('1');  % 当前帧是否检测到手指1
    finger2Detected = fingerActiveStates('2');  % 当前帧是否检测到手指2
    
    if finger1Detected && finger2Detected
        currentGesture = '平移';
    elseif ~finger1Detected && finger2Detected
        currentGesture = '左键按下';
        if ~isLeftPressed
            mouse.mousePress(InputEvent.BUTTON1_MASK);
            isLeftPressed = true;
        end
    elseif finger1Detected && ~finger2Detected
        currentGesture = '右键按下';
        if ~isRightPressed
            mouse.mousePress(InputEvent.BUTTON3_MASK);
            isRightPressed = true;
        end
    else 
        currentGesture = '未检测到手势';
    end

    if strcmp(currentGesture, '未检测到手势') || strcmp(currentGesture, '平移')
        if isLeftPressed
            mouse.mouseRelease(InputEvent.BUTTON1_MASK);
            isLeftPressed = false;
        end
        if isRightPressed
            mouse.mouseRelease(InputEvent.BUTTON3_MASK);
            isRightPressed = false;
        end
    end

    if finger2Detected
        if isempty(lastPosition2)
            lastPosition2 = lastPositions('2');
        else
            import java.awt.MouseInfo;
            import java.awt.Point;

            currentPosition = MouseInfo.getPointerInfo().getLocation();
            x = currentPosition.x;
            y = currentPosition.y;

            currentPosition2 = lastPositions('2');
            movement2 = currentPosition2 - lastPosition2;
            % 判断移动是否超过阈值
            if abs(movement2(1)) < moveThreshold && abs(movement2(2)) < moveThreshold
                % 如果移动没有超过阈值，则不移动鼠标
                moveParams = [0,0];
            else
                % 如果移动超过阈值，则按比例调整鼠标移动
                moveParams = [movement2(1)*scaleFactor, movement2(2)*scaleFactor];
            end

            newX = x + round(moveParams(1));
            newY = y + round(moveParams(2));
            mouse.mouseMove(newX, newY);

            % 更新lastPosition2
            lastPosition2 = currentPosition2;
            
        end
    else
        lastPosition2 = []; % 当2号手指不被检测到时重置其位置
    end

    % 显示原视频
    imshow(frame, 'Parent', hAx1);
    title(hAx1, '原始视频');

    % 显示处理中的视频
    imshow(filteredFrame, 'Parent', hAx2);
    title(hAx2, '处理中的画面');

    % 显示处理后的标号视频
    imshow(labeledFrame, 'Parent', hAx3);
    title(hAx3, '处理后的视频');

    % 显示当前手势状态
    cla(hAx4)
    text(0.5, 0.5, currentGesture, 'HorizontalAlignment', 'center', 'Units', 'normalized', 'Parent', hAx4);
    title(hAx4, '当前手势状态');

    pause(0.05);
end

% 清理并释放摄像头资源
clear('cam');
close(hFig);